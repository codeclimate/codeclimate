require "spec_helper"

describe CC::Config do
  describe "load" do
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
      expect(config.engines).to include(CC::Config::Engine.new("complexity-ruby"))
      expect(config.engines).to include(CC::Config::Engine.new("duplication"))
      expect(config.engines).to include(CC::Config::Engine.new("rubocop"))
      expect(config.exclude_patterns).to include("**/*.rb")
      expect(config.exclude_patterns).to include("foo/")
      expect(config.prepare.fetch.each.to_a).to include(CC::Config::Prepare::Fetch::Entry.new("rubocop.yml"))
    end

    it "only uses default config if .codeclimate.yml doesn't exist" do
      # .codeclimate.yml is in this codebase.
      stub_const("CC::Config::YAML::DEFAULT_PATH", "")

      config = CC::Config.load

      expect(config.engines.count).to eq(2)
      expect(config.engines).to include(CC::Config::Engine.new("complexity-ruby"))
      expect(config.engines).to include(CC::Config::Engine.new("duplication"))
    end

    def write_cc_yaml(json)
      Tempfile.open("") do |tmp|
        tmp.puts(json)
        tmp.rewind

        stub_const("CC::Config::YAML::DEFAULT_PATH", tmp.path)
      end
    end
  end
end
