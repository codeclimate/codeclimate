module CC
  class Config
    module Validation
      class JSON < FileValidator

        private

        def validate
          @data = ::JSON.parse(File.read(path))

          return unless validate_hash_data

          validate_prepare
          validate_engines("plugins")
          validate_checks
          validate_exclude_pattern("exclude_patterns")

          warn_unrecognized_keys(%w[prepare plugins exclude_patterns version])
        rescue ::JSON::ParserError => ex
          errors << "Unable to parse: #{ex.message}"
        end
      end
    end
  end
end
