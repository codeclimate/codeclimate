require "spec_helper"

module CC::Analyzer
  describe EngineRegistry do
    describe "#[]" do
      it "returns an entry of engines.yml" do
        registry = EngineRegistry.new

        expect(registry["madeup"]).to eq nil
        expect(registry["rubocop"]["channels"]["stable"]).to eq "codeclimate/codeclimate-rubocop"
      end

      it "returns a fake registry entry if in dev mode" do
        registry = EngineRegistry.new(true)

        expect(registry["madeup"]).to eq(
          "channels" => { "stable" => "codeclimate/codeclimate-madeup:latest" }
        )
      end
    end
  end
end
