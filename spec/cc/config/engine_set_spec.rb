require "spec_helper"

describe CC::Config::EngineSet do
  describe ".new" do
    it "gives a properly ordered set including plugins" do
      engines = described_class.new(
        "rubocop" => { "enabled" => true, "config" => "foobar" },
        "duplication" => { "enabled" => true, "channel" => "blah" },
        "structure" => { "enabled" => false },
      ).engines

      expect(engines.length).to eq(3)

      expect(engines[0].name).to eq("structure")
      expect(engines[0]).not_to be_enabled
      expect(engines[0].channel).to eq(CC::Config::Engine::DEFAULT_CHANNEL)
      expect(engines[0].config).to eq("enabled" => false)

      expect(engines[1].name).to eq("duplication")
      expect(engines[1]).to be_enabled
      expect(engines[1].channel).to eq("blah")
      expect(engines[1].config).to eq("enabled" => true, "channel" => "blah")

      expect(engines[2].name).to eq("rubocop")
      expect(engines[2]).to be_enabled
      expect(engines[2].channel).to eq(CC::Config::Engine::DEFAULT_CHANNEL)
      expect(engines[2].config).to eq("enabled" => true, "config" => "foobar")
    end

    it "maps exclude_patterns to the engine" do
      engines = described_class.new(
        "rubocop" => { "enabled" => true, "exclude_patterns" => ["foo"] },
      ).engines

      expect(engines[0].name).to eq("rubocop")
      expect(engines[0].exclude_patterns).to eq(["foo"])
    end
  end
end
