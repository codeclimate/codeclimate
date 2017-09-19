require "spec_helper"

describe CC::Config::ChecksAdapter do
  it "does nothing when no checks" do
    config = described_class.new(
      "plugins" => {
        "structure" => { "enabled" => true },
      },
    ).config

    expect(config).to eq(
      "plugins" => {
        "structure" => { "enabled" => true },
      },
    )
  end

  it "copies checks for QM engines" do
    config = described_class.new(
      "plugins" => {
        "structure" => { "enabled" => true, "config" => "somefile" },
        "duplication" => { "enabled" => true },
        "rubocop" => { "enabled" => true },
      },
      "checks" => {
        "complex-logic" => { "enabled" => false },
      },
    ).config

    expect(config).to eq(
      "plugins" => {
        "structure" => {
          "enabled" => true,
          "config" => {
            "file" => "somefile",
            "checks" => { "complex-logic" => { "enabled" => false } },
          },
        },
        "duplication" => {
          "enabled" => true,
          "config" => {
            "checks" => { "complex-logic" => { "enabled" => false } },
          },
        },
        "rubocop" => { "enabled" => true },
      },
      "checks" => {
        "complex-logic" => { "enabled" => false },
      },
    )
  end
end
