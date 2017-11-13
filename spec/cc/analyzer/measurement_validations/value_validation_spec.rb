require "spec_helper"

module CC::Analyzer::MeasurementValidations
  describe ValueValidation do
    describe "#valid?" do
      it "returns true for int" do
        expect(described_class.new("value" => 42)).to be_valid
      end

      it "returns true for float" do
        expect(described_class.new("value" => 4.2)).to be_valid
      end

      it "returns false for missing key" do
        expect(described_class.new({})).not_to be_valid
      end

      it "returns false for key with string" do
        expect(described_class.new("value" => "42")).not_to be_valid
      end
    end
  end
end
