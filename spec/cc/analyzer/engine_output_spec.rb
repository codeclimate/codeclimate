require "spec_helper"

module CC::Analyzer
  describe EngineOutput do
    describe "#issue?" do
      it "returns true if the output is an issue" do
        output = { type: "issue" }.to_json

        expect(EngineOutput.new(output).issue?).to eq(true)
      end
    end
  end
end
