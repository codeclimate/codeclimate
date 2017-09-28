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
          validate_key_type("exclude_patterns", [Array])

          validate_checks

          warn_unrecognized_keys(%w[enabled channel checks config exclude_patterns])
        end

        def validate_root
          if !data.is_a?(Hash) && ![true, false].include?(data)
            errors << "section must be a boolean or a hash"
            return false
          end
          true
        end

        def validate_checks
          return unless validate_key_type("checks", Hash)

          data.fetch("checks", {}).each do |check_name, check_data|
            validator = CheckValidator.new(check_data)
            errors.push(*validator.errors)
            warnings.push(*validator.warnings)
          end
        end
      end
    end
  end
end
