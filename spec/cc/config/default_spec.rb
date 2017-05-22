require "spec_helper"

describe CC::Config::Default do
  describe "#engines" do
    it "returns hash in checks key" do
      write_cc_json(<<-EOS)
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

      config = described_class.new

      expect(config.engines.count).to eq(2)

      expect(config.engines.any? { |engine| engine.name == "complexity-ruby" }).to eq(true)
      expect(config.engines.any? { |engine| engine.name == "duplication" }).to eq(true)

      config.engines.each do |engine|
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

  def write_cc_json(json)
    Tempfile.open("") do |tmp|
      tmp.puts(json)
      tmp.rewind

      stub_const("CC::Config::JSON::DEFAULT_PATH", tmp.path)
    end
  end
end
