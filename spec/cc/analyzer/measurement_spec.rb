require "spec_helper"

module CC::Analyzer
  describe Measurement do
    describe "#as_json" do
      it "adds engine_name to JSON" do
        doc = { type: "measurement", name: "foo", value: 42 }
        measurement = described_class.new("engine", doc.to_json)
        expect(measurement.as_json).to eq(
          "engine_name" => "engine",
          "name" => "foo",
          "type" => "measurement",
          "value" => 42,
        )
      end
    end

    describe "#to_json" do
      it "is the encoding of #as_json" do
        doc = { type: "measurement", name: "foo", value: 42 }
        measurement = described_class.new("engine", doc.to_json)
        expect(measurement.to_json).to eq(measurement.as_json.to_json)
      end
    end
  end
end
