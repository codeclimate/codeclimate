module CC
  module Analyzer
    class Issue
      class Builder
        attr_reader :error, :issue

        def initialize(json)
          @json = json
        end

        def run
          validate
          @issue = Issue.new(adapter.hash) unless @error
        end

        private

        def invalid_json?
          JSON.parse(@json)
          false
        rescue JSON::ParserError
          true
        end

        def invalid_json_error
          CC::Analyzer::Engine::OutputInvalid.new(
            "Issue unparseable: #{@json}",
            output: @json,
          )
        end

        def invalid_location?
          !adapter.hash
        end

        def invalid_location_error
          CC::Analyzer::Engine::IssueInvalid.new(
            "Issue has invalid location: #{hash_from_json}",
            output: hash_from_json,
          )
        end

        def hash_from_json
          @hash_from_json ||= JSON.parse(@json)
        end

        def location_is_directory?
          File.directory?(Issue.path(adapter.hash))
        end

        def location_is_directory_error
          CC::Analyzer::Engine::IssueInvalid.new(
            "Issue location is directory: #{hash_from_json}",
            output: hash_from_json,
          )
        end

        def adapter
          @adapter ||= Adapter.new(hash_from_json).tap(&:run)
        end

        def validate
          if invalid_json?
            @error = invalid_json_error
          elsif !validator.valid?
            @error = validator.engine_output_error
          elsif invalid_location?
            @error = invalid_location_error
          elsif location_is_directory?
            @error = location_is_directory_error
          end
        end

        def validator
          @validator ||= Validator.new(hash_from_json).tap(&:validate)
        end
      end
    end
  end
end
