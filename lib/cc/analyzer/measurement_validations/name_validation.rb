module CC
  module Analyzer
    module MeasurementValidations
      class NameValidation < Validation
        REGEX = /^[A-Za-z0-9_]+$/

        def valid?
          name && name.is_a?(String) && REGEX.match?(name)
        end

        def message
          "Name must be present and contain only letters, numbers, dots, and underscores"
        end

        private

        def name
          object["name"]
        end
      end
    end
  end
end
