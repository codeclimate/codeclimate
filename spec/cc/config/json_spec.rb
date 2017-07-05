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

  describe "#exclude_paths" do
    it "respects excludes from JSON" do
      json = load_cc_json(<<-EOS)
        {
          "exclude_patterns": [
            "tests/",
            "**/vendor/"
          ]
        }
      EOS

      expect(json.exclude_patterns).to eq(%w[tests/ **/vendor/])
    end

    it "gives defaults when key not in JSON" do
      json = load_cc_json(<<-EOS)
        {}
      EOS

      expect(json.exclude_patterns).to eq(CC::Config::Default::EXCLUDE_PATTERNS)
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
