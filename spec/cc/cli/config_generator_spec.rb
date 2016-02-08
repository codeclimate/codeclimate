require "spec_helper"
require "cc/cli/config_generator"
require "cc/cli/upgrade_config_generator"

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
        expect(generator.class).to eq ConfigGenerator
      end

      it "returns a standard generator when upgrade requested but .codeclimate.yml does not exist" do
        generator = ConfigGenerator.for(make_filesystem, engine_registry, true)
        expect(generator.class).to eq ConfigGenerator
      end

      it "returns an upgrade generator when requested" do
        File.write(".codeclimate.yml", create_classic_yaml)
        generator = ConfigGenerator.for(make_filesystem, engine_registry, true)
        expect(generator.class).to eq UpgradeConfigGenerator
      end
    end

    describe "#can_generate?" do
      it "is true" do
        expect(generator.can_generate?).to eq true
      end
    end

    describe "#eligible_engines" do
      it "calculates eligible_engines based on existing files" do
        write_fixture_source_files

        expected_engine_names = %w(rubocop eslint csslint fixme duplication)
        expected_engines = engine_registry.list.select do |name, _|
          expected_engine_names.include?(name)
        end
        expect(generator.eligible_engines).to eq expected_engines
      end

      it "returns brakeman when Gemfile.lock exists" do
        File.write("Gemfile.lock", "gemfile-lock-content")

        expected_engine_names = %w(bundler-audit fixme)
        expected_engines = engine_registry.list.select do |name, _|
          expected_engine_names.include?(name)
        end
        expect(generator.eligible_engines).to eq expected_engines
      end

      it "does not enable an engine based on excluded paths" do
        make_tree <<-EOM
          foo.rb
          vendor/other.js
        EOM

        expect(generator.eligible_engines.keys).not_to include("eslint")
      end

      it "raises if the workspace is empty" do
        expect { generator.eligible_engines }.to raise_error(CC::CLI::ConfigGenerator::EmptyWorkspaceError)
      end
    end

    describe "#errors" do
      it "is empty array" do
        expect(generator.errors).to eq []
      end
    end

    describe "#exclude_paths" do
      it "uses AUTO_EXCLUDE_PATHS that exist locally" do
        write_fixture_source_files

        expected_paths = %w(config/ spec/ vendor/)
        expect(generator.exclude_paths).to eq expected_paths
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
