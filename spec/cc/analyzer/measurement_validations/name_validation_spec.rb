require "spec_helper"

module CC::Analyzer::MeasurementValidations
  describe NameValidation do
    describe "#valid?" do
      it "returns true" do
        expect(described_class.new("name" => "foo")).to be_valid
      end

      it "returns true for name with periods" do
        expect(described_class.new("name" => "foo.bar")).to be_valid
      end

      it "returns true for name with hyphens" do
        expect(described_class.new("name" => "foo-bar")).to be_valid
      end

      it "returns false for missing key" do
        expect(described_class.new({})).not_to be_valid
      end

      it "returns false for key with number" do
        expect(described_class.new("name" => 42)).not_to be_valid
      end

      it "returns false for key with spaces" do
        expect(described_class.new("name" => "42 foo")).not_to be_valid
      end
    end
  end
end
