require "spec_helper"

describe CC::Config do
  include FileSystemHelpers

  context "CLI-required attributes" do
    it "has #development and #analysis_paths support" do
      config = described_class.new

      expect(config).not_to be_development
      expect(config.analysis_paths).to be_empty

      config.development = true
      config.analysis_paths << "a-path"

      expect(config).to be_development
      expect(config.analysis_paths).to eq(%w[a-path])
    end
  end

  describe ".load" do
    around do |test|
      within_temp_dir { test.call }
    end

    it "loads json & applies defaults, ignoring yaml" do
      yaml = write_cc_yaml(<<-EOYAML)
      prepare:
        fetch:
        - rubocop.yml
      plugins:
        rubocop:
          enabled: true
      exclude_patterns:
      - "**/*.rb"
      - foo/
      EOYAML

      json = write_cc_json(<<-EOS)
      {
        "checks": {
          "cyclomatic-complexity": {
            "enabled": true
          },
          "similar-code": {
            "enabled": false
          }
        }
      }
      EOS

      config = CC::Config.load

      expect(config.engines.count).to eq(2)
      expect(config.engines).to include(CC::Config::Engine.new("structure"))
      expect(config.engines).to include(CC::Config::Engine.new("duplication"))
      expect(config.exclude_patterns).not_to include("**/*.rb")
      expect(config.prepare.fetch.each.to_a).to be_empty

      config.engines.find { |e| e.name == "structure" }.tap do |engine|
        expect(engine.config["config"]["checks"]).to eq(
          "cyclomatic-complexity" => {
            "enabled" => true,
          },
          "similar-code" => {
            "enabled" => false,
          },
        )
      end

      config.engines.find { |e| e.name == "duplication" }.tap do |engine|
        expect(engine.config["config"]["checks"]).to eq(
          "cyclomatic-complexity" => {
            "enabled" => true,
          },
          "similar-code" => {
            "enabled" => false,
          },
        )
      end
    end

    it "loads yaml & applies defaults" do
      yaml = write_cc_yaml(<<-EOYAML)
      prepare:
        fetch:
        - rubocop.yml
      plugins:
        rubocop:
          enabled: true
      exclude_patterns:
      - "**/*.rb"
      - foo/
      EOYAML

      config = CC::Config.load

      expect(config.engines.count).to eq(3)
      expect(config.engines).to include(CC::Config::Engine.new("structure"))
      expect(config.engines).to include(CC::Config::Engine.new("duplication"))
      expect(config.engines).to include(CC::Config::Engine.new("rubocop"))
      expect(config.exclude_patterns).to include("**/*.rb")
      expect(config.exclude_patterns).to include("foo/")
      expect(config.prepare.fetch.each.to_a).to eq([CC::Config::Prepare::Fetch::Entry.new("rubocop.yml")])
    end

    it "adds files fetched in prepare step to exclude_patterns" do
      yaml = write_cc_yaml(<<-EOYAML)
      prepare:
        fetch:
        - rubocop.yml
        - url: https://google.com/
          path: ignore/this.json
        - url: https://test.com/nopath.yml
      plugins:
        rubocop:
          enabled: true
      exclude_patterns:
      - "**/*.rb"
      - foo/
      EOYAML

      config = CC::Config.load

      expect(config.exclude_patterns).to match_array(["**/*.rb", "foo/", "rubocop.yml", "ignore/this.json", "nopath.yml"])
      expect(config.prepare.fetch.paths).to match_array(["rubocop.yml", "ignore/this.json", "nopath.yml"])
    end

    it "doesn't add any files to exclude_patterns if no prepare step is specified" do
      yaml = write_cc_yaml(<<-EOYAML)
      plugins:
        rubocop:
          enabled: true
      exclude_patterns:
      - "**/*.rb"
      - foo/
      EOYAML

      config = CC::Config.load

      expect(config.exclude_patterns).to match_array(["**/*.rb", "foo/"])
      expect(config.prepare.fetch.paths).to be_empty
    end

    it "loads prepare from JSON" do
      yaml = write_cc_json(<<-EOJSON)
      {
        "prepare": {
          "fetch": [
            "rubocop.yml"
          ]
        },
        "plugins": {
          "rubocop": {
            "enabled": true
          }
        },
        "exclude_patterns": [
          "**/*.rb",
          "foo/"
        ]
      }
      EOJSON

      config = CC::Config.load

      expect(config.engines.count).to eq(3)
      expect(config.engines).to include(CC::Config::Engine.new("structure"))
      expect(config.engines).to include(CC::Config::Engine.new("duplication"))
      expect(config.engines).to include(CC::Config::Engine.new("rubocop"))
      expect(config.exclude_patterns).to include("**/*.rb")
      expect(config.exclude_patterns).to include("foo/")
      expect(config.prepare.fetch.each.to_a).to eq([CC::Config::Prepare::Fetch::Entry.new("rubocop.yml")])
    end

    it "only uses default config if .codeclimate.yml doesn't exist" do
      stub_const("CC::Config::YAMLAdapter::DEFAULT_PATH", "")
      stub_const("CC::Config::JSONAdapter::DEFAULT_PATH", "")

      config = CC::Config.load

      expect(config.engines.count).to eq(2)
      expect(config.engines).to include(CC::Config::Engine.new("structure"))
      structure = config.engines.detect { |e| e.name == "structure" }
      expect(structure).to be_enabled
      duplication = config.engines.detect { |e| e.name == "duplication" }
      expect(duplication).to be_enabled
    end

    def write_cc_yaml(yaml)
      make_file(CC::Config::YAMLAdapter::DEFAULT_PATH, yaml)
    end

    def write_cc_json(json)
      make_file(CC::Config::JSONAdapter::DEFAULT_PATH, json)
    end
  end

  describe "#disable_plugins!" do
    it "deletes plugins from #engines" do
      config = CC::Config.new(engines: Set.new(
        [
          double(name: "1", plugin?: false),
          double(name: "2", plugin?: true),
          double(name: "3", plugin?: false),
        ]
      ))

      config.disable_plugins!

      expect(config.engines.count).to eq(2)
      expect(config.engines.map(&:name)).to eq(%w[1 3])
    end
  end
end
