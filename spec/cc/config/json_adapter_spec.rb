require "spec_helper"

describe CC::Config::JSONAdapter do
  describe "#engines" do
    it "loads JSON" do
      json = load_cc_json(<<-EOS)
        {
          "checks": {
            "cyclomatic-complexity": {
              "enabled": true
            }
          }
        }
      EOS

      expect(json.config).to eq(
        "checks" => {
          "cyclomatic-complexity" => {
            "enabled" => true,
          },
        },
      )
    end
  end

  def load_cc_json(json)
    Tempfile.open("") do |tmp|
      tmp.puts(json)
      tmp.rewind

      described_class.load(tmp.path)
    end
  end
end
