require "spec_helper"

describe CC::Config::JSON do
  describe "#engines" do
    it "includes structure engine with checks config" do
      json = load_cc_json(<<-EOS)
        {
          "checks": {
            "cyclomatic-complexity": {
              "enabled": true
            }
          }
        }
      EOS

      expect(json.engines.count).to eq(2)

      json.engines.first.tap do |engine|
        expect(engine.config["config"]["checks"]).to eq(
          "cyclomatic-complexity" => {
            "enabled" => true,
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
