require "spec_helper"
require "cc/cli/upgrade_config_generator"

module CC::CLI
  describe UpgradeConfigGenerator do
    include Factory
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "#can_generate?" do
      it "is true when existing config is valid" do
        File.write(".codeclimate.yml", create_classic_yaml)

        expect(generator.can_generate?).to eq true
      end

      it "is false when existing config is not valid" do
        File.write(".codeclimate.yml", %{
          z%$:::::/
          languages:
            Ruby: true
          exclude_paths:
            - excluded.rb
        })

        expect(generator.can_generate?).to eq false
      end
    end

    describe "#eligible_engines" do
      it "calculates eligible_engines based on classic languages & source files" do
        File.write(".codeclimate.yml", create_classic_yaml)
        write_fixture_source_files

        expected_engine_names = %w(rubocop csslint fixme duplication)
        expected_engines = engine_registry.list.select do |name, _|
          expected_engine_names.include?(name)
        end
        expect(generator.eligible_engines).to eq expected_engines
      end
    end

    describe "#exclude_paths" do
      it "uses existing exclude_paths from yaml" do
        File.write(".codeclimate.yml", create_classic_yaml)

        expected_paths = %w(excluded.rb)
        expect(generator.exclude_paths).to eq expected_paths
      end

      it "uses existing exclude_paths from yaml when coerced from string" do
        File.write(".codeclimate.yml", %{
          languages:
            Ruby: true
          exclude_paths: excluded.rb
        })

        expected_paths = %w(excluded.rb)
        expect(generator.exclude_paths).to eq expected_paths
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
