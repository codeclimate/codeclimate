require "spec_helper"

module CC::Analyzer::MeasurementValidations
  describe TypeValidation do
    describe "#valid?" do
      it "returns true" do
        expect(TypeValidation.new("type" => "measurement")).to be_valid
      end

      it "returns false" do
        expect(TypeValidation.new("type" => "issue")).not_to be_valid
      end
    end
  end
end
