require "spec_helper"
require "file_utils_ext"

module CC::Analyzer
  describe EnginesRunner do
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    before do
      system("git init > /dev/null")
    end

    it "builds and runs enabled engines from the registry with the formatter" do
      config = config_with_engine("an_engine")
      registry = registry_with_engine("an_engine")
      formatter = null_formatter

      expect_engine_run("an_engine", "/code", formatter)
      FileUtils.stubs(:readable_by_all?).at_least_once.returns(true)

      EnginesRunner.new(registry, formatter, "/code", config).run
    end

    it "raises for no enabled engines" do
      config = stub(engines: {})
      runner = EnginesRunner.new({}, null_formatter, "/code", config)

      lambda { runner.run }.must_raise(EnginesRunner::NoEnabledEngines)
    end

    describe "when the formatter does not respond to #close" do
      let(:config) { config_with_engine("an_engine") }
      let(:formatter) do
        formatter = stub(started: nil, write: nil, run: nil, finished: nil)
        formatter.stubs(:engine_running).yields
        formatter
      end
      let(:registry) { registry_with_engine("an_engine") }

      it "does not call #close" do
        expect_engine_run("an_engine", "/code", formatter)
        FileUtils.stubs(:readable_by_all?).at_least_once.returns(true)
        EnginesRunner.new(registry, formatter, "/code", config).run
      end
    end

    describe "when an engine container exits with non-zero status" do
      let(:config) { config_with_engine("bad_engine") }
      let(:container_name) { "cc-engines-123-asdf" }
      let(:formatter) { null_formatter }
      let(:image_name) { "codeclimate/bad-engine:b52" }
      let(:registry) { registry_with_engine("bad_engine") }

      before do
        FileUtils.mkdir_p("/tmp/cc")
        container_result = stub(
          "Container::Result",
          timed_out?: false,
          exit_status: 123,
          stderr: "Oopsie"
        )
        container = stub("Container", run: container_result)
        container.stubs(:on_output).yields
        Container.stubs(:new).returns(container)
      end

      it "raises EngineFailure for the CLI" do
        runner = EnginesRunner.new(registry, formatter, "/code", config)
        -> { runner.run }.must_raise(Engine::EngineFailure)
      end
    end

    def registry_with_engine(name)
      { name => { "image" => "codeclimate/codeclimate-#{name}" } }
    end

    def config_with_engine(name)
      CC::Yaml.parse(<<-EOYAML)
        engines:
          #{name}:
            enabled: true
      EOYAML
    end

    def expect_engine_run(name, source_dir, formatter, engine_config = nil)
      container_result = stub(
        "Container::Result", timed_out?: false, exit_status: 0, stderr: ""
      )
      engine = stub(name: name)
      engine.expects(:run).
        with(formatter, kind_of(ContainerListener)).
        returns(container_result)

      image = "codeclimate/codeclimate-#{name}"
      engine_config ||= {
        "enabled" => true,
        exclude_paths: [],
        include_paths: ["./"]
      }

      Engine.expects(:new).
        with(name, { "image" => image }, source_dir, engine_config, anything).
        returns(engine)
    end

    def null_formatter
      formatter = stub(started: nil, write: nil, run: nil, finished: nil, close: nil)
      formatter.stubs(:engine_running).yields
      formatter
    end
  end
end
