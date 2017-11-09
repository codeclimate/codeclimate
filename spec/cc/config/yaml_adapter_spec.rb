require "spec_helper"

describe CC::Config::YAMLAdapter do
  describe "#engines" do
    it "moves engines to plugins" do
      yaml = load_cc_yaml(<<-EOYAML)
      engines:
        rubocop:
          enabled: true
      EOYAML

      expect(yaml.config).to eq(
        "plugins" => {
          "rubocop" => { "enabled" => true }
        }
      )
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

      expect(yaml.config["plugins"].length).to eq(3)
      expect(yaml.config["plugins"].keys).to eq(
        %w[rubocop eslint tslint],
      )
    end

    it "supports a plugin:true|false shorthand" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop: true
        eslint: false
      EOYAML

      plugins = yaml.config["plugins"]
      expect(plugins["rubocop"]).to eq("enabled" => true)
      expect(plugins["eslint"]).to eq("enabled" => false)
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

      _, config = yaml.config["plugins"].detect { |name, _| name == "rubocop" }
      expect(config).to eq(
        "enabled" => true, "channel" => "beta", "config" => { "yo" => "sup" },
      )
    end

    it "re-writes as legacy file config values" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop:
          enabled: true
          config:
            file: "foo.rb"
      EOYAML

      _, config = yaml.config["plugins"].detect { |name, _| name == "rubocop" }
      expect(config).to eq(
        "enabled" => true, "config" => "foo.rb",
      )
    end

    it "respects legacy file config values" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop:
          enabled: true
          config: "foo.rb"
      EOYAML

      _, config = yaml.config["plugins"].detect { |name, _| name == "rubocop" }
      expect(config).to eq(
        "enabled" => true, "config" => "foo.rb",
      )
    end

    it "updates legacy engine excludes" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop:
          exclude_paths:
          - foo
      EOYAML

      _, config = yaml.config["plugins"].detect { |name, _| name == "rubocop" }
      expect(config).to eq(
        "exclude_patterns" => ["foo"],
      )
    end

    it "does not overwrite engine excludes with legacy" do
      yaml = load_cc_yaml(<<-EOYAML)
      plugins:
        rubocop:
          exclude_paths:
          - bar
          exclude_patterns:
          - foo
      EOYAML

      _, config = yaml.config["plugins"].detect { |name, _| name == "rubocop" }
      expect(config).to eq(
        "exclude_paths" => ["bar"],
        "exclude_patterns" => ["foo"],
      )
    end
  end

  describe "#exclude_patterns" do
    it "uses explicitly-configured excludes when defined" do
      yaml = load_cc_yaml(<<-EOYAML)
      exclude_patterns:
      - "**/*.rb"
      - foo/
      EOYAML

      expect(yaml.config["exclude_patterns"]).to eq(%w[**/*.rb foo/])
    end

    it "converts legacy exclude_paths" do
      yaml = load_cc_yaml(<<-EOYAML)
      exclude_paths:
      - "**/*.rb"
      - foo/
      EOYAML

      expect(yaml.config["exclude_patterns"]).to eq(%w[**/*.rb foo/])
    end

    it "converts legacy engine exclude_paths from a string" do
      yaml = load_cc_yaml(<<-EOYAML)
      engines:
        foo:
          exclude_paths:
            - "**/*.rb"
            - foo/
      EOYAML

      expect(yaml.config["plugins"]["foo"]["exclude_patterns"]).to eq(%w[**/*.rb foo/])
    end

    it "converts legacy engine exclude_paths" do
      yaml = load_cc_yaml(<<-EOYAML)
      engines:
        foo:
          exclude_paths:
            foo/
      EOYAML

      expect(yaml.config["plugins"]["foo"]["exclude_patterns"]).to eq(%w[foo/])
    end
  end

  def load_cc_yaml(yaml)
    Tempfile.open("") do |tmp|
      tmp.puts(yaml)
      tmp.rewind

      described_class.load(tmp.path)
    end
  end
end
