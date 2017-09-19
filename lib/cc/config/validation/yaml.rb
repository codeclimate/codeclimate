module CC
  class Config
    module Validation
      class YAML < FileValidator

        private

        def validate
          @data = ::YAML.safe_load(File.read(path))

          return unless validate_hash_data

          validate_prepare

          validate_one_of(%w[engines plugins])
          validate_one_of(%w[exclude_paths exclude_patterns])

          validate_engines("engines")
          validate_engines("plugins")

          validate_checks

          validate_key_type("exclude_patterns", Array)
          validate_key_type("exclude_paths", Array)

          validate_exclude_pattern_schema("exclude_patterns")
          validate_exclude_pattern_schema("exclude_paths")

          deprecated_key_warnings
        rescue Psych::SyntaxError => ex
          errors << "Unable to parse: #{ex.message}"
        end

        def validate_one_of(keys)
          num = keys.map { |k| data.key?(k) }.select(&:present?).count
          if num > 1
            wrapped_keys = keys.map { |k| "'#{k}'" }
            errors << "only use one of #{wrapped_keys.join(", ")}"
          end
        end

        def deprecated_key_warnings
          deprecate_key("engines", "plugins")
          deprecate_key("exclude_paths", "exclude_patterns")
          deprecate_key("languages")
          deprecate_key("ratings")
        end

        def deprecate_key(key, new_key = nil)
          if data.key?(key)
            if new_key.nil?
              warnings << "'#{key}' has been deprecated, and will not be used"
            else
              warnings << "'#{key}' has been deprecated, please use '#{new_key}' instead"
            end
          end
        end
      end
    end
  end
end
