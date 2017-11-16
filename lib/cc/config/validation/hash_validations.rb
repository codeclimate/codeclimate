module CC
  class Config
    module Validation
      module HashValidations
        def validate_hash_data
          unless data.is_a?(Hash)
            errors << "Config file should contain a hash, not a #{data.class.to_s.downcase}"
            return false
          end
          true
        end

        def validate_key_type(key, types)
          if types.is_a?(Class)
            return validate_key_type(key, [types])
          elsif data.key?(key)
            unless types.include?(data[key].class)
              errors << key_type_error_message(key, types)
              return false
            end
          end
          true
        end

        def key_type_error_message(key, types)
          if types.one?
            klass_name = types[0].to_s.downcase
            article =
              if klass_name[0] == "a"
                "an"
              else
                "a"
              end
            "'#{key}' must be #{article} #{klass_name}"
          elsif types == [TrueClass, FalseClass]
            "'#{key}' must be a boolean"
          else
            type_names = types.map(&:to_s).map(&:downcase)
            "'#{key}' must be one of #{type_names.join(", ")}"
          end
        end

        def warn_unrecognized_keys(recognized_keys)
          unknown_keys = data.keys.reject { |k| recognized_keys.include?(k) }
          unknown_keys.each do |key|
            warnings << "unrecognized key '#{key}'"
          end
        end
      end
    end
  end
end
