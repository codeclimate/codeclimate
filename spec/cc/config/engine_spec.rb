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
end
