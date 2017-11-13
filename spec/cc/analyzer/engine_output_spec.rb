require "spec_helper"

module CC::Analyzer
  describe EngineOutput do
    describe "#issue?" do
      it "returns true if the output is an issue" do
        output = { type: "issue" }.to_json

        expect(EngineOutput.new("", output).issue?).to eq(true)
      end
    end

    describe "#valid?" do
      it "is true for a valid issue" do
        output = sample_issue.to_json
        expect(EngineOutput.new("engine", output)).to be_valid
      end

      it "is true for a valid meaure" do
        output = { type: "measurement", name: "foo", value: 42 }.to_json
        expect(EngineOutput.new("engine", output)).to be_valid
      end

      it "is false for an invalid issue" do
        output = { type: "issue", categories: ["Foo"] }.to_json
        expect(EngineOutput.new("engine", output)).not_to be_valid
      end

      it "is false for an invalid measurement" do
        output = { type: "measurement", value: "Foo" }.to_json
        expect(EngineOutput.new("engine", output)).not_to be_valid
      end

      it "is false for invalid JSON" do
        output = "{bad"
        expect(EngineOutput.new("engine", output)).not_to be_valid
      end
    end

    describe "#error" do
      it "gets IssueValidator errors for invalid issue" do
        output = { type: "issue", categories: ["Foo"] }.to_json
        expect(EngineOutput.new("engine", output).error[:message]).to match(
          "Category must be at least one of"
        )
      end

      it "gets MeasureValidator errors for invalid measures" do
        output = { type: "measurement", value: "Foo" }.to_json
        expect(EngineOutput.new("engine", output).error[:message]).to match(
          "Value must be present and numeric"
        )
      end

      it "is appropriate for invalid JSON" do
        output = "{bad"
        expect(EngineOutput.new("engine", output).error[:message]).to match(
          "Invalid JSON"
        )
      end
    end

    describe "#to_json" do
      it "is JSON for an issue" do
        str = sample_issue.to_json
        output = EngineOutput.new("engine", str)

        expect(output.to_json).to eq(Issue.new("engine", str).to_json)
      end

      it "is JSON for a measurement" do
        str = { type: "measurement", name: "foo", value: 42 }.to_json
        output = EngineOutput.new("engine", str)

        expect(output.to_json).to eq(Measurement.new("engine", str).to_json)
      end
    end
  end
end
