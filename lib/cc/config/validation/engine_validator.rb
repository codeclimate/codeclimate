module CC
  class Config
    module Validation
      class EngineValidator
        include HashValidations

        RECOGNIZED_KEYS = %w[
          enabled
          channel
          checks
          config
          exclude_fingerprints
          exclude_patterns
        ].freeze

        attr_reader :errors, :warnings

        def initialize(data, legacy: false)
          @data = data
          @legacy = legacy

          @errors = []
          @warnings = []

          validate
        end

        def valid?
          errors.none?
        end

        private

        attr_reader :data

        def legacy?
          @legacy
        end

        def validate
          validate_root
          return unless data.is_a?(Hash)

          validate_key_type("enabled", [TrueClass, FalseClass])
          validate_key_type("channel", String)
          validate_key_type("config", [String, Hash])
          validate_key_type("exclude_patterns", Array)
          if legacy?
            validate_exclude_paths
          end

          validate_checks
          validate_exclude_fingerprints

          if legacy?
            warn_unrecognized_keys(RECOGNIZED_KEYS + %w[exclude_paths])
          else
            warn_unrecognized_keys(RECOGNIZED_KEYS)
          end
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

          data.fetch("checks", {}).each do |_check_name, check_data|
            validator = CheckValidator.new(check_data)
            errors.push(*validator.errors)
            warnings.push(*validator.warnings)
          end
        end

        def validate_exclude_paths
          validate_key_type("exclude_paths", [Array, String])
          if data.key?("exclude_paths")
            warnings << "'exclude_paths' has been deprecated, please use 'exclude_patterns' instead"
          end
        end

        def validate_exclude_fingerprints
          validate_key_type("exclude_fingerprints", Array)
        end
      end
    end
  end
end
