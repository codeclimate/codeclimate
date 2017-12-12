require "spec_helper"

module CC::CLI
  describe Analyze do
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "#run" do
      it "sends expected engines to bridge" do
        write_cc_yaml(<<-EOYAML)
        {}
        EOYAML

        expect_bridge(
          config: match_engines([
            CC::Config::Engine.new("structure", enabled: true, config: { "enabled" => true, "channel" => "stable" }),
            CC::Config::Engine.new("duplication", enabled: true, channel: "stable", config: { "enabled" => true, "channel" => "stable" }),
          ])
        )

        command = described_class.new
        command.run
      end

      it "respects -e for an unconfigured engine" do
        write_cc_yaml(<<-EOYAML)
        plugins:
          rubocop:
            enabled: true
        EOYAML

        expect_bridge(
          config: match_engines([
            CC::Config::Engine.new("structure", enabled: false, config: { "enabled" => true, "channel" => "stable" }),
            CC::Config::Engine.new("duplication", enabled: false, channel: "stable", config: { "enabled" => true, "channel" => "stable" }),
            CC::Config::Engine.new("rubocop", enabled: false, channel: "stable", config: { "enabled" => true }),
            CC::Config::Engine.new("eslint", enabled: true, channel: "stable"),
          ])
        )

        command = described_class.new(["-e", "eslint"])
        command.run
      end

      it "respects -e for an already configured engine" do
        write_cc_yaml(<<-EOYAML)
        plugins:
          rubocop:
            enabled: true
            config:
              file: myconfig.yml
        EOYAML

        expect_bridge(
          config: match_engines([
            CC::Config::Engine.new("structure", enabled: false, config: { "enabled" => true, "channel" => "stable" }),
            CC::Config::Engine.new("duplication", enabled: false, channel: "stable", config: { "enabled" => true, "channel" => "stable" }),
            CC::Config::Engine.new("rubocop", enabled: true, channel: "stable", config: { "enabled" => true, "config" => "myconfig.yml" }),
          ])
        )

        command = described_class.new(["-e", "rubocop"])
        command.run
      end

      it "respects multiple -e" do
        write_cc_yaml(<<-EOYAML)
        plugins:
          rubocop:
            enabled: true
            exclude_patterns:
            - foo
        EOYAML

        expect_bridge(
          config: match_engines([
            CC::Config::Engine.new("structure", enabled: false, config: { "enabled" => true, "channel" => "stable" }),
            CC::Config::Engine.new("duplication", enabled: false, channel: "stable", config: { "enabled" => true, "channel" => "stable" }),
            CC::Config::Engine.new("rubocop", enabled: true, channel: "stable", exclude_patterns: ["foo"], config: { "enabled" => true, "exclude_patterns" => ["foo"] }),
            CC::Config::Engine.new("eslint", enabled: true, channel: "stable"),
          ])
        )

        command = described_class.new(["-e", "eslint", "-e", "rubocop"])
        command.run
      end

      it "respects multiple -e with channel" do
        write_cc_yaml(<<-EOYAML)
        plugins:
          rubocop:
            enabled: true
            exclude_patterns:
            - foo
        EOYAML

        expect_bridge(
          config: match_engines([
            CC::Config::Engine.new("structure", enabled: false, config: { "enabled" => true, "channel" => "stable" }),
            CC::Config::Engine.new("duplication", enabled: true, channel: "stable", config: { "enabled" => true, "channel" => "stable" }),
            CC::Config::Engine.new("rubocop", enabled: true, channel: "foo", exclude_patterns: ["foo"], config: { "enabled" => true, "exclude_patterns" => ["foo"] }),
            CC::Config::Engine.new("eslint", enabled: true, channel: "bar"),
          ])
        )

        command = described_class.new(["-e", "duplication", "-e", "eslint:bar", "-e", "rubocop:foo"])
        command.run
      end
    end

    def write_cc_yaml(yaml)
      make_file(CC::Config::YAMLAdapter::DEFAULT_PATH, yaml)
    end

    def expect_bridge(config:)
      stub_bridge = double(:bridge)
      expect(stub_bridge).to receive(:run)

      expect(CC::Analyzer::Bridge).to receive(:new) do |args|
        expect(args[:config]).to config
        expect(args[:formatter]).to be_a_kind_of(CC::Analyzer::Formatters::Formatter)
        expect(args[:listener]).to be_an_instance_of(CC::Analyzer::CompositeContainerListener)
        expect(args[:registry]).to be_an_instance_of(CC::EngineRegistry)
        stub_bridge
      end
    end
  end
end
