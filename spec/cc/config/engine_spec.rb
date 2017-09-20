require "spec_helper"

describe CC::Config::Engine do
  it "has default values" do
    engine = described_class.new("rubocop")

    expect(engine).not_to be_enabled
    expect(engine.name).to eq("rubocop")
    expect(engine.channel).to eq(described_class::DEFAULT_CHANNEL)
    expect(engine.config).to be_empty
    expect(engine.exclude_patterns).to eq([])
  end

  it "can be enabled, for a non-default channel, and have config" do
    engine = described_class.new(
      "duplication",
      enabled: true,
      channel: "beta",
      config: {
        "config" => {
          "languages" => %w[ruby]
        },
        "exclude_paths" => [""],
      },
    )

    expect(engine).to be_enabled
    expect(engine.channel).to eq("beta")
    expect(engine.config["config"]["languages"]).to eq(%w[ruby])
  end

  describe "#plugin?" do
    it "returns true for plugin engines" do
      expect(described_class.new("eslint")).to be_plugin
      expect(described_class.new("rubocop")).to be_plugin
      expect(described_class.new("whatever")).to be_plugin
    end

    it "returns false for our engines" do
      expect(described_class.new("duplication")).not_to be_plugin
      expect(described_class.new("structure")).not_to be_plugin
    end
  end
end
