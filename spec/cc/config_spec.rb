require "spec_helper"

describe CC::Config do
  describe ".load" do
    it "loads default then json, ignoring yaml" do
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
        expect(engine.config["config"]["languages"].length).to eq(5)
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

    it "loads default then yaml configurations" do
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
      expect(config.prepare.fetch.each.to_a).to include(CC::Config::Prepare::Fetch::Entry.new("rubocop.yml"))
    end

    it "only uses default config if .codeclimate.yml doesn't exist" do
      stub_const("CC::Config::YAML::DEFAULT_PATH", "")
      stub_const("CC::Config::JSON::DEFAULT_PATH", "")

      config = CC::Config.load

      expect(config.engines.count).to eq(2)
      expect(config.engines).to include(CC::Config::Engine.new("structure"))
      expect(config.engines).to include(CC::Config::Engine.new("duplication"))
    end

    def write_cc_yaml(json)
      Tempfile.open("") do |tmp|
        tmp.puts(json)
        tmp.rewind

        stub_const("CC::Config::YAML::DEFAULT_PATH", tmp.path)
      end
    end

    def write_cc_json(json)
      Tempfile.open("") do |tmp|
        tmp.puts(json)
        tmp.rewind

        stub_const("CC::Config::JSON::DEFAULT_PATH", tmp.path)
      end
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
