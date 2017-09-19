module CC
  class Config
    module Validation
      class EngineValidator
        include HashValidations

        attr_reader :errors, :warnings

        def initialize(data)
          @data = data

          @errors = []
          @warnings = []

          validate
        end

        def valid?
          errors.none?
        end

        private

        attr_reader :data

        def validate
          validate_root
          return unless data.is_a?(Hash)

          validate_key_type("enabled", [TrueClass, FalseClass])
          validate_key_type("channel", String)
          validate_key_type("config", [String, Hash])
        end

        def validate_root
          if !data.is_a?(Hash) && ![true, false].include?(data)
            errors << "section must be a boolean or a hash"
            return false
          end
          true
        end
      end
    end
  end
end
