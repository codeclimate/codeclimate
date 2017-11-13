module CC
  module Analyzer
    module MeasurementValidations
      class Validation
        def initialize(object)
          @object = object
        end

        def valid?
          raise NotImplementedError
        end

        def message
          raise NotImplementedError
        end

        private

        attr_reader :object

        def type
          object["type"]
        end
      end
    end
  end
end
