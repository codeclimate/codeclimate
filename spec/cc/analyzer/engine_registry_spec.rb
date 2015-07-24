require "spec_helper"

module CC::Analyzer
  describe EngineRegistry do
    describe "#[]" do
      it "returns an entry of engines.yml" do
        registry = EngineRegistry.new

        registry["madeup"].must_equal nil
        registry["rubocop"]["image"].must_equal "codeclimate/codeclimate-rubocop"
      end

      it "returns a fake registry entry if in dev mode" do
        registry = EngineRegistry.new(true)

        registry["madeup"].must_equal(
          "image" => "codeclimate/codeclimate-madeup:latest"
        )
      end
    end
  end
end
