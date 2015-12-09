module CC
  module Analyzer
    class Issue
      class Builder
        attr_reader :error, :issue

        def initialize(json, engine_name)
          @json = json
          @engine_name = engine_name
        end

        def run
          validate
          @issue = Engine::Issue.new(smell_adapter.hash) unless @error
        end

        private

        def invalid_json?
          JSON.parse(@json)
          false
        rescue JSON::ParserError
          true
        end

        def invalid_json_error
          IOProcessor::EngineOutputError.new(
            CC::Builder::Engine::OutputInvalid,
            "Issue unparseable: #{@json}",
            output: @json,
          )
        end

        def invalid_location?
          !smell_adapter.hash
        end

        def invalid_location_error
          IOProcessor::EngineOutputError.new(
            CC::Builder::Engine::IssueInvalid,
            "Issue has invalid location: #{hash_from_json}",
            output: hash_from_json,
          )
        end

        def hash_from_json
          @hash_from_json ||= JSON.parse(@json)
        end

        def location_is_directory?
          File.directory?(Engine::Issue.path(smell_adapter.hash))
        end

        def location_is_directory_error
          IOProcessor::EngineOutputError.new(
            CC::Builder::Engine::IssueInvalid,
            "Issue location is directory: #{hash_from_json}",
            output: hash_from_json,
          )
        end

        def smell_adapter
          @smell_adapter ||= SmellAdapter.new(hash_from_json, @engine_name).tap(&:run)
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
          @validator ||= IssueValidator.new(hash_from_json).tap(&:validate)
        end
      end
    end
  end
end
