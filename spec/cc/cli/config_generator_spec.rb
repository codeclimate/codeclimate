require "spec_helper"
require "cc/cli/config_generator"

module CC::CLI
  describe ConfigGenerator do
    include Factory
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "self.for" do
      it "returns a standard generator when upgrade not requested" do
        generator = ConfigGenerator.for(make_filesystem, engine_registry, false)
        generator.class.must_equal ConfigGenerator
      end

      it "returns a standard generator when upgrade requested but .codeclimate.yml does not exist" do
        generator = ConfigGenerator.for(make_filesystem, engine_registry, true)
        generator.class.must_equal ConfigGenerator
      end

      it "returns an upgrade generator when requested" do
        File.write(".codeclimate.yml", create_classic_yaml)
        generator = ConfigGenerator.for(make_filesystem, engine_registry, true)
        generator.class.must_equal UpgradeConfigGenerator
      end
    end

    describe "#eligible_engines" do
      it "calculates eligible_engines based on existing files" do
        write_fixture_source_files

        expected_engine_names = %w(rubocop eslint csslint)
        expected_engines = engine_registry.list.select do |name, _|
          expected_engine_names.include?(name)
        end
        generator.eligible_engines.must_equal expected_engines
      end

      it "returns brakeman when Gemfile.lock exists" do
        File.write("Gemfile.lock", "gemfile-lock-content")

        expected_engines = engine_registry.list.select do |name, _|
          "bundler-audit" == name
        end
        generator.eligible_engines.must_equal expected_engines
      end
    end

    describe "#exclude_paths" do
      it "uses AUTO_EXCLUDE_PATHS that exist locally" do
        write_fixture_source_files

        expected_paths = %w(config/ spec/ vendor/)
        generator.exclude_paths.must_equal expected_paths
      end
    end

    def generator
      @generator ||= ConfigGenerator.new(make_filesystem, engine_registry)
    end

    def engine_registry
      @engine_registry ||= CC::Analyzer::EngineRegistry.new
    end
  end
end
