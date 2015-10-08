require "spec_helper"
require "cc/cli/upgrade_config_generator"

module CC::CLI
  describe UpgradeConfigGenerator do
    include Factory
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "#eligible_engines" do
      it "calculates eligible_engines based on classic languages & source files" do
        File.write(".codeclimate.yml", create_classic_yaml)
        write_fixture_source_files

        expected_engine_names = %w(rubocop csslint duplication)
        expected_engines = engine_registry.list.select do |name, _|
          expected_engine_names.include?(name)
        end
        generator.eligible_engines.must_equal expected_engines
      end
    end

    describe "#exclude_paths" do
      it "uses existing exclude_paths from yaml" do
        File.write(".codeclimate.yml", create_classic_yaml)
        write_fixture_source_files

        expected_paths = %w(excluded.rb)
        generator.exclude_paths.must_equal expected_paths
      end
    end

    def generator
      @generator ||= UpgradeConfigGenerator.new(make_filesystem, engine_registry)
    end

    def engine_registry
      @engine_registry ||= CC::Analyzer::EngineRegistry.new
    end
  end
end
