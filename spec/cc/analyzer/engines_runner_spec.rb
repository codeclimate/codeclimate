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

    it "does not raise for invalid engine names" do
      config = config_with_engine("an_engine")
      runner = EnginesRunner.new({}, null_formatter, "/code", config)

      lambda { runner.run }
    end

    it "raises for no enabled engines" do
      config = stub(engines: {})
      runner = EnginesRunner.new({}, null_formatter, "/code", config)

      lambda { runner.run }.must_raise(EnginesRunner::NoEnabledEngines)
    end

    it "massages data for the config" do
      config = CC::Yaml.parse <<-EOYAML
        engines:
          rubocop:
            enabled: true
            config:
              file: rubocop.yml
      EOYAML
      registry = registry_with_engine("rubocop")
      formatter = null_formatter

      FileUtils.stubs(:readable_by_all?).at_least_once.returns(true)
      expected_config = {
        "enabled" => true,
        "config" => "rubocop.yml",
        :exclude_paths => [],
        :include_paths => ["./"]
      }

      expect_engine_run("rubocop", "/code", formatter, expected_config)

      EnginesRunner.new(registry, formatter, "/code", config).run
    end

    it "respects .gitignore paths" do
      make_file(".ignorethis")
      make_file(".gitignore", ".ignorethis\n")
      config = CC::Yaml.parse <<-EOYAML
        engines:
          rubocop:
            enabled: true
      EOYAML
      registry = registry_with_engine("rubocop")
      formatter = null_formatter

      FileUtils.stubs(:readable_by_all?).at_least_once.returns(true)
      expected_config = {
        "enabled" => true,
        :exclude_paths => %w[.ignorethis],
        :include_paths => %w[.gitignore]
      }

      expect_engine_run("rubocop", "/code", formatter, expected_config)

      EnginesRunner.new(registry, formatter, "/code", config).run
    end

    describe "when the source directory contains all readable files, and there are no ignored files" do
      let(:engines_config) { config_with_engine("an_engine") }
      let(:formatter) { null_formatter }
      let(:registry) { registry_with_engine("an_engine") }

      before do
        make_file("root_file.rb")
        make_file("subdir/subdir_file.rb")
      end

      it "gets include_paths from IncludePathBuilder" do
        IncludePathsBuilder.expects(:new).with([], []).returns(mock(build: ['.']))
        expected_config = {
          "enabled" => true,
          :exclude_paths => [],
          :include_paths => ['.']
        }
        expect_engine_run("an_engine", "/code", formatter, expected_config)
        EnginesRunner.new(registry, formatter, "/code", engines_config).run
      end
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

    describe "when there are multiple engines" do
      let(:config) do
        CC::Yaml.parse(<<-EOYAML)
          engines:
            eslint:
              enabled: true
            rubocop:
              enabled: true
        EOYAML
      end
      let(:formatter) { null_formatter }
      let(:registry) do
        {
          "eslint" => { "image" => "codeclimate/codeclimate-eslint" },
          "rubocop" => { "image" => "codeclimate/codeclimate-rubocop" }
        }
      end
      let(:runner) do
        EnginesRunner.new(registry, formatter, "/code", config)
      end

      it "yields each engine in response to #each_engine" do
        engines_yielded = []
        runner.each_engine do |engine|
          engines_yielded << engine
        end
        engines_yielded.size.must_equal(2)
        engines_yielded.map(&:name).include?("eslint").must_equal(true)
        engines_yielded.map(&:name).include?("rubocop").must_equal(true)
      end

      it "accepts different listeners per engine and uses them in the container for their respective engines" do
        listeners = []
        runner.each_engine do |engine|
          listener = stub("ContainerListener #{engine.name}")
          listeners << listener
          runner.set_container_listener(engine, listener)
          engine.expects(:run).with(formatter, listener)
        end
        runner.run
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
      engine = stub(name: name)
      engine.expects(:run).
        with(formatter, kind_of(ContainerListener))

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
