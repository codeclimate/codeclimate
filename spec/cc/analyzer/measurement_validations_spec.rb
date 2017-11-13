require "spec_helper"

module CC::Analyzer
  describe MeasurementValidations do
    describe ".validations" do
      it "gets the validation classes" do
        expected = [
          MeasurementValidations::NameValidation,
          MeasurementValidations::TypeValidation,
          MeasurementValidations::ValueValidation,
        ]

        expect(MeasurementValidations.validations).to eq(expected)
      end
    end
  end
end
