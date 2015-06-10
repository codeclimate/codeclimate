require "spec_helper"
require "cc/analyzer"


describe CC::Analyzer::Config do
  describe "#engine_present?(engine_name)" do
    describe "when the given engine is not present in yaml file" do
      it "returns false" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_without_jshint)

        parsed_yaml.engine_present?("jshint").must_equal(false)
      end
    end

    describe "when the engine is present in yaml file" do
      it "returns false" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_with_rubocop_enabled)

        parsed_yaml.engine_present?("rubocop").must_equal(true)
      end
    end
  end

  describe "#engine_config" do
    it "returns the config" do
      config = CC::Analyzer::Config.new(Factory.yaml_with_rubocop_enabled)
      config.engine_config("rubocop").must_equal({"enabled" => true})
    end

    it "returns an empty hash" do
      config = CC::Analyzer::Config.new(Factory.yaml_with_rubocop_enabled)
      config.engine_config("bugfixer").must_equal({})
    end
  end

  describe "#engine_enabled?(engine_name)" do
    describe "when the engine is enabled" do
      it "returns true" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_with_rubocop_enabled)

        parsed_yaml.engine_enabled?("rubocop").must_equal(true)
      end
    end

    describe "when the engine is not enabled" do
      it "returns false" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_without_rubocop_enabled)

        parsed_yaml.engine_enabled?("rubocop").must_equal(false)
      end
    end
  end

  describe "#enable_engine(engine_name)" do
    describe "when the engine is present but unabled" do
      it "enables engine" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_without_rubocop_enabled)
        parsed_yaml.engine_enabled?("rubocop").must_equal(false)

        parsed_yaml.enable_engine("rubocop")

        parsed_yaml.engine_enabled?("rubocop").must_equal(true)
      end
    end

    describe "when the engine is not present" do
      it "adds engine to list of engines and enables it" do
        parsed_yaml = CC::Analyzer::Config.new(Factory.yaml_without_jshint)
        parsed_yaml.engine_present?("jshint").must_equal(false)

        parsed_yaml.enable_engine("jshint")

        parsed_yaml.engine_enabled?("jshint").must_equal(true)
      end
    end
  end
end

