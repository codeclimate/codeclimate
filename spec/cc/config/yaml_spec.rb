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

  describe "#reload" do
    it "re-reads and resets" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop: true
        eslint: true
      EOYAML
      expect(yaml.engines.length).to eq(4)

      yaml.engines.pop(2)
      expect(yaml.engines.length).to eq(2)

      yaml.reload
      expect(yaml.engines.length).to eq(4)
    end
  end

  describe "#engines" do
    it "includes default engines" do
      yaml = load_cc_yaml("")

      expect(yaml.engines.length).to eq(2)
      expect(yaml.engines.map(&:name)).to match_array(%w[complexity-ruby duplication])
    end

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

      expect(yaml.engines.length).to eq(4)
      expect(yaml.engines.map(&:name)).to include("rubocop")
      expect(yaml.engines.map(&:name)).to include("eslint")
      expect(yaml.engines.map(&:name)).not_to include("tslint")
    end

    it "supports a plugin:true|false shorthand" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop: true
        eslint: false
      EOYAML

      expect(yaml.engines.length).to eq(3)
      expect(yaml.engines.map(&:name)).to include("rubocop")
      expect(yaml.engines.map(&:name)).not_to include("eslint")
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
      expect(rubocop.config).to eq("yo" => "sup")
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
      expect(rubocop.config).to eq("foo.rb")
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

    it "uses defaults if not configured" do
      yaml = load_cc_yaml("")

      expect(yaml.exclude_patterns).to eq(CC::Config::Default::EXCLUDE_PATTERNS)
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
