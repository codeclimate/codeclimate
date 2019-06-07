module CC
  module Analyzer
    module MeasurementValidations
      class TypeValidation < Validation
        def valid?
          type&.casecmp("measurement")&.zero?
        end

        def message
          "Type must be 'measurement' but was '#{type}'"
        end
      end
    end
  end
end
