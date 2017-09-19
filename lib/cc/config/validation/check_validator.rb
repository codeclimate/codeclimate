module CC
  class Config
    module Validation
      class CheckValidator
        include HashValidations

        attr_reader :errors, :warnings

        def initialize(data)
          @data = data

          @errors = []
          @warnings = []

          validate
        end

        private

        attr_reader :data

        def validate
          unless data.is_a?(Hash)
            errors << "must be a hash"
            return
          end

          validate_key_type("enabled", [TrueClass, FalseClass])
          validate_key_type("config", Hash)
        end
      end
    end
  end
end
