module CC
  module Analyzer
    module MeasurementValidations
      autoload :NameValidation, "cc/analyzer/measurement_validations/name_validation"
      autoload :TypeValidation, "cc/analyzer/measurement_validations/type_validation"
      autoload :ValueValidation, "cc/analyzer/measurement_validations/value_validation"
      autoload :Validation, "cc/analyzer/measurement_validations/validation"

      def self.validations
        constants.sort.map(&method(:const_get)).select do |klass|
          klass.is_a?(Class) && klass.superclass == Validation
        end
      end
    end
  end
end
