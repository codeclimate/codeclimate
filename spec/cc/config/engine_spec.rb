require "spec_helper"

describe CC::Config::Engine do
  it "has default values" do
    engine = described_class.new("rubocop")

    expect(engine).not_to be_enabled
    expect(engine.name).to eq("rubocop")
    expect(engine.channel).to eq(described_class::DEFAULT_CHANNEL)
    expect(engine.config).to be_empty
  end

  it "can be enabled, for a non-default channel, and have config" do
    engine = described_class.new(
      "duplication",
      enabled: true,
      channel: "beta",
      config: { languages: %w[ruby] },
    )

    expect(engine).to be_enabled
    expect(engine.channel).to eq("beta")
    expect(engine.config).to eq(languages: %w[ruby])
  end

  describe "#to_config_json" do
    it "returns channel and configuration" do
      engine = described_class.new(
        "duplication",
        channel: "beta",
        config: { languages: %w[ruby] },
      )

      expect(engine.to_config_json.fetch("channel")).to eq("beta")
      expect(engine.to_config_json.fetch("config")).to eq(languages: %w[ruby])
    end
  end
end
