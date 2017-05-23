require "spec_helper"

describe CC::Config::YAML do
  context "CLI-required attributes" do
    it "has #development and #analysis_paths support" do
      yaml = load_cc_yaml("")

      expect(yaml).not_to be_development
      expect(yaml.analysis_paths).to be_empty

      yaml.development = true
      yaml.analysis_paths << "a-path"

      expect(yaml).to be_development
      expect(yaml.analysis_paths).to eq(%w[a-path])
    end
  end

  describe "#engines" do
    it "includes enabled plugins" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop:
          enabled: true
        eslint:
          enabled: true
        tslint:
          enabled: false
      EOYAML

      expect(yaml.engines.length).to eq(3)
      expect(yaml.engines.map(&:name)).to eq(
        %w[rubocop eslint tslint],
      )
    end

    it "supports a plugin:true|false shorthand" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop: true
        eslint: false
      EOYAML

      rubocop, eslint = yaml.engines.to_a
      expect(rubocop).to be_enabled
      expect(eslint).not_to be_enabled
    end

    it "respects channel, and config" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop:
          enabled: true
          channel: beta
          config:
            yo: "sup"
      EOYAML

      rubocop = yaml.engines.detect { |e| e.name == "rubocop" }
      expect(rubocop).to be_present
      expect(rubocop).to be_enabled
      expect(rubocop.channel).to eq("beta")
      expect(rubocop.config["config"]).to eq("yo" => "sup")
    end

    it "re-writes as legacy file config values" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop:
          enabled: true
          config:
            file: "foo.rb"
      EOYAML

      rubocop = yaml.engines.detect { |e| e.name == "rubocop" }
      expect(rubocop).to be_present
      expect(rubocop.config["config"]).to eq("foo.rb")
    end
  end

  describe "#exclude_patterns" do
    it "uses explicitly-configured excludes when defined" do
      yaml = load_cc_yaml(<<-EOYAML)
      exclude_patterns:
      - "**/*.rb"
      - foo/
      EOYAML

      expect(yaml.exclude_patterns).to eq(%w[**/*.rb foo/])
    end
  end

  def load_cc_yaml(yaml)
    Tempfile.open("") do |tmp|
      tmp.puts(yaml)
      tmp.rewind

      described_class.new(tmp.path)
    end
  end
end
