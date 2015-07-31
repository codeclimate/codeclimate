require "spec_helper"

module CC::Analyzer
  describe EnginesRunner do
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

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

      expected_config = {
        "enabled" => true,
        "config" => "rubocop.yml",
        :exclude_paths => []
      }

      expect_engine_run("rubocop", "/code", formatter, expected_config)

      EnginesRunner.new(registry, formatter, "/code", config).run
    end

    it "respects .gitignore paths" do
      system("git init > /dev/null")
      make_file(".ignorethis")
      make_file(".gitignore", ".ignorethis\n")
      config = CC::Yaml.parse <<-EOYAML
        engines:
          rubocop:
            enabled: true
      EOYAML
      registry = registry_with_engine("rubocop")
      formatter = null_formatter

      expected_config = {
        "enabled" => true,
        :exclude_paths => %w[ .ignorethis ]
      }

      expect_engine_run("rubocop", "/code", formatter, expected_config)

      EnginesRunner.new(registry, formatter, "/code", config).run
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
      engine.expects(:run).with(formatter)

      image = "codeclimate/codeclimate-#{name}"
      engine_config ||= { "enabled" => true, exclude_paths: [] }

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
