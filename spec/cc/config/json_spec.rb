require "spec_helper"

describe CC::Config::JSON do
  describe "#exclude" do
    it "returns hash in checks key" do
      json = load_cc_json(<<-EOS)
      {
        "checks": {
          "ruby-cyclomatic-complexity": {
            "enabled": true,
            "config": {
              "threshold": 20
            }
          }
        }
      }
      EOS

      expect(json.checks).to eq(
        "ruby-cyclomatic-complexity" => {
          "enabled" => true,
          "config" => {
            "threshold" => 20,
          },
        },
      )
    end

    it "returns empty hash if checks key doesn't exist" do
      json = load_cc_json(<<-EOS)
      {
        "foo": "bar"
      }
      EOS

      expect(json.checks).to eq({})
    end

    it "returns empty hash if file doesn't exist" do
      json = described_class.new("missing.json")
      expect(json.checks).to eq({})
    end
  end

  def load_cc_json(json)
    Tempfile.open("") do |tmp|
      tmp.puts(json)
      tmp.rewind

      described_class.new(tmp.path)
    end
  end
end
