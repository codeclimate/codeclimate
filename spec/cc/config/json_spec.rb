require "spec_helper"

describe CC::Config::JSON do
  describe "#engines" do
    it "includes structure engine with checks config" do
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

      expect(json.engines.count).to eq(1)

      json.engines.first.tap do |engine|
        expect(engine.config["config"]["checks"]).to eq(
          "ruby-cyclomatic-complexity" => {
            "enabled" => true,
            "config" => {
              "threshold" => 20,
            },
          },
        )
      end
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
