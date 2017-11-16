require "uri"
require "pathname"

module CC
  class Config
    module Validation
      class FetchValidator
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
          if data.is_a?(String)
            validate_url(data)
          elsif data.is_a?(Hash)
            validate_fetch_hash
          else
            errors << "fetch section should be a string or a hash"
          end
        end

        def validate_url(url)
          unless valid_url?(url)
            errors << "fetch section: invalid URL '#{url}'"
          end
        end

        def valid_url?(url)
          uri = URI.parse(url)
          uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        rescue URI::InvalidURIError
          false
        end

        def validate_fetch_hash
          if !data.key?("path") || !data.key?("url")
            errors << "fetch section must include 'url' & 'path'"
          end

          validate_key_type("path", String)
          validate_key_type("url", String)

          validate_path(data["path"])
          validate_url(data["url"])

          warn_unrecognized_keys(%w[path url])
        end

        def validate_path(path)
          if path.nil? || path.length.zero?
            errors << "fetch section's 'path' cannot be empty"
          else
            pathname = Pathname.new(path)
            if pathname.absolute?
              errors << "fetch section: absolute path '#{path}' is invalid"
            end
            if pathname.cleanpath.to_s != pathname.to_s || path.include?("..")
              errors << "fetch section: relative path elements in '#{path}' are invalid"
            end
          end
        end
      end
    end
  end
end
