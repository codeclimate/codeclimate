module CC
  module Analyzer
    class MeasurementValidator
      include Validator

      def self.validations
        MeasurementValidations.validations
      end
    end
  end
end
