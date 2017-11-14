require "spec_helper"

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

      EnginesRunner.new(registry, formatter, "/code", config).run
    end

    it "raises for no enabled engines" do
      config = double(engines: {}, exclude_paths: [])
      runner = EnginesRunner.new({}, null_formatter, "/code", config)

      expect { runner.run }.to raise_error(EnginesRunner::NoEnabledEngines)
    end

    describe "partial flag" do
      let(:config) { config_with_engine("steam") }
      let(:registry) { registry_with_engine("steam") }
      let(:whatever) { [anything] * 6 }
      let(:engine_config) do
        double(
          name: "Steam",
          registry_entry: {},
          code_path: "/code",
          config: {},
          container_label: nil
        )
      end

      [true, false].each do |flag|
        it "passes partial flag to engine config builder: #{flag.inspect}" do
          allow(Engine).to receive(:new).and_return(double name: "Steam", run: nil)
          allow(EnginesConfigBuilder).to receive(:new).and_return(double run: [engine_config])

          EnginesRunner.new(registry, null_formatter, "/code", config, [], nil, flag).run

          expect(EnginesConfigBuilder).to have_received(:new).with(
            registry: anything,
            config: anything,
            container_label: anything,
            source_dir: anything,
            requested_paths: anything,
            partial: flag,
          )
        end
      end
    end

    describe "when the formatter does not respond to #close" do
      let(:config) { config_with_engine("an_engine") }
      let(:formatter) do
        formatter = double(started: nil, write: nil, run: nil, finished: nil)
        allow(formatter).to receive(:engine_running).and_yield
        formatter
      end
      let(:registry) { registry_with_engine("an_engine") }

      it "does not call #close" do
        expect_engine_run("an_engine", "/code", formatter)
        EnginesRunner.new(registry, formatter, "/code", config).run
      end
    end

    def registry_with_engine(name)
      {
        name => {
          "channels" => {
            "stable" => "codeclimate/codeclimate-#{name}"
          }
        }
      }
    end

    def config_with_engine(name)
      CC::Yaml.parse(<<-EOYAML)
        engines:
          #{name}:
            enabled: true
      EOYAML
    end

    def expect_engine_run(name, source_dir, formatter, engine_config = nil)
      engine = double(name: name)
      expect(engine).to receive(:run).
        with(formatter, kind_of(ContainerListener))

      image = "codeclimate/codeclimate-#{name}"
      engine_config ||= {
        "enabled" => true,
        include_paths: ["./"]
      }

      expect(Engine).to receive(:new).
        and_return(engine)
        # with(name, { "image" => image }, source_dir, engine_config, anything).
        # and_return(engine)
    end

    def null_formatter
      formatter = double(started: nil, write: nil, run: nil, finished: nil, close: nil)
      allow(formatter).to receive(:engine_running).and_yield
      formatter
    end
  end
end
