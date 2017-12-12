require "spec_helper"

describe CC::Config::DefaultAdapter do
  it "populates defaults over empty config" do
    config = described_class.new({}).config

    expect(config).to eq(
      "plugins" => {
        "structure" => { "enabled" => true, "channel" => "stable" },
        "duplication" => { "enabled" => true, "channel" => "stable" },
      },
      "exclude_patterns" => described_class::EXCLUDE_PATTERNS,
    )
  end

  it "respects existing plugins" do
    config = described_class.new(
      "plugins" => {
        "structure" => { "enabled" => true, "channel" => "beta" },
        "duplication" => { "enabled" => false },
        "rubocop" => { "enabled" => true },
      },
    ).config

    expect(config).to eq(
      "plugins" => {
        "structure" => { "enabled" => true, "channel" => "beta" },
        "duplication" => { "enabled" => false, "channel" => "stable" },
        "rubocop" => { "enabled" => true },
      },
      "exclude_patterns" => described_class::EXCLUDE_PATTERNS,
    )
  end

  it "respects existing excludes" do
    config = described_class.new(
      "plugins" => {
        "rubocop" => { "enabled" => true },
      },
      "exclude_patterns" => ["foo/", "bar/"],
    ).config

    expect(config).to eq(
      "plugins" => {
        "structure" => { "enabled" => true, "channel" => "stable" },
        "duplication" => { "enabled" => true, "channel" => "stable" },
        "rubocop" => { "enabled" => true },
      },
      "exclude_patterns" => ["foo/", "bar/"],
    )
  end
end
