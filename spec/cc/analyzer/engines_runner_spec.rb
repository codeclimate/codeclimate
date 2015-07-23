require "spec_helper"

module CC::Analyzer
  describe EnginesRunner do
    it "builds and runs enabled engines from the registry with the formatter" do
      config = config_with_engine("an_engine")
      registry = registry_with_engine("an_engine")
      formatter = null_formatter

      expect_engine_run("an_engine", "/code", formatter)

      EnginesRunner.new(registry, formatter, "/code", config).run
    end

    it "raises for invalid engine names" do
      config = config_with_engine("an_engine")
      runner = EnginesRunner.new({}, null_formatter, "/code", config)

      lambda { runner.run }.must_raise(EnginesRunner::InvalidEngineName)
    end

    it "raises for no enabled engines" do
      config = stub(engines: {})
      runner = EnginesRunner.new({}, null_formatter, "/code", config)

      lambda { runner.run }.must_raise(EnginesRunner::NoEnabledEngines)
    end

    def registry_with_engine(name)
      { name => { "image" => "codeclimate/codeclimate-#{name}" } }
    end

    def config_with_engine(name)
      stub(engines: { name => { "enabled" => true } }, exclude_paths: nil)
    end

    def expect_engine_run(name, source_dir, formatter)
      engine = stub(name: "an_engine")
      engine.expects(:run).with(formatter)

      image = "codeclimate/codeclimate-#{name}"
      engine_config = { "enabled" => true, exclude_paths: [] }

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
