require "spec_helper"
require "cc/analyzer"


describe CC::Analyzer::Config do
  describe "#engine_present?(engine_name)" do
    describe "when the given engine is not present in yaml file" do
      it "returns false" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_without_jshint)

        expect(parsed_yaml.engine_present?("jshint")).to eq(false)
      end
    end

    describe "when the engine is present in yaml file" do
      it "returns false" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_with_rubocop_enabled)

        expect(parsed_yaml.engine_present?("rubocop")).to eq(true)
      end
    end
  end

  describe "#engine_names" do
    it "returns only enabled engines" do
      yaml = %{
        engines:
          rubocop:
            enabled: false
          curses:
            enabled: true
        }
      config = CC::Analyzer::Config.new(yaml)
      expect(config.engine_names).to eq(["curses"])
    end
  end

  describe "#engine_config" do
    it "returns the config" do
      config = CC::Analyzer::Config.new(Factory.yaml_with_rubocop_enabled)
      expect(config.engine_config("rubocop")).to eq({"enabled" => true})
    end

    it "returns an empty hash" do
      config = CC::Analyzer::Config.new(Factory.yaml_with_rubocop_enabled)
      expect(config.engine_config("bugfixer")).to eq({})
    end
  end

  describe "#engine_enabled?(engine_name)" do
    describe "when the engine is enabled" do
      it "returns true" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_with_rubocop_enabled)

        expect(parsed_yaml.engine_enabled?("rubocop")).to eq(true)
      end
    end

    describe "when the engine is not enabled" do
      it "returns false" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_without_rubocop_enabled)

        expect(parsed_yaml.engine_enabled?("rubocop")).to eq(false)
      end
    end
  end

  describe "#enable_engine(engine_name)" do
    describe "when the engine is present but unabled" do
      it "enables engine" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_without_rubocop_enabled)
        expect(parsed_yaml.engine_enabled?("rubocop")).to eq(false)

        parsed_yaml.enable_engine("rubocop")

        expect(parsed_yaml.engine_enabled?("rubocop")).to eq(true)
      end
    end

    describe "when the engine is not present" do
      it "adds engine to list of engines and enables it" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_without_jshint)
        expect(parsed_yaml.engine_present?("jshint")).to eq(false)

        parsed_yaml.enable_engine("jshint")

        expect(parsed_yaml.engine_enabled?("jshint")).to eq(true)
      end
    end
  end
end

