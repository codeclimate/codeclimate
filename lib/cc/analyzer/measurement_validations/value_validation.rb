module CC
  module Analyzer
    module MeasurementValidations
      class ValueValidation < Validation
        def valid?
          value&.is_a?(Numeric)
        end

        def message
          "Value must be present and numeric"
        end

        private

        def value
          object["value"]
        end
      end
    end
  end
end
