module CC
  module Analyzer
    class Issue
      module Validations
        autoload :CheckNamePresenceValidation, "cc/analyzer/issue/validator/check_name_presence_validation"
        autoload :PathPresenceValidation, "cc/analyzer/issue/validator/path_presence_validation"
        autoload :RelativePathValidation, "cc/analyzer/issue/validator/relative_path_validation"
        autoload :TypeValidation, "cc/analyzer/issue/validator/type_validation"
      end

      class Validator
        CHECKS = [
          Validations::CheckNamePresenceValidation,
          Validations::PathPresenceValidation,
          Validations::RelativePathValidation,
          Validations::TypeValidation,
        ].freeze

        attr_reader :error

        def initialize(issue)
          @issue = issue
        end

        def valid?
          @error.blank?
        end

        def validate
          if invalid_messages.any?
            @error = {
              message: "#{invalid_messages.join(", ")}: `#{issue}`.",
              issue: issue,
            }
            false
          else
            true
          end
        end

        #TODO: adapt this to still work with builder
        #def engine_output_error
        #  IOProcessor::EngineOutputError.new(
        #    CC::Builder::Engine::IssueInvalid,
        #    @error[:message],
        #    output: @error[:message], issue: @error[:issue],
        #  )
        #end

        private

        attr_reader :issue

        def invalid_messages
          @invalid_messages ||= CHECKS.each_with_object([]) do |check, result|
            validator = check.new(issue)
            result << validator.message unless validator.valid?
          end
        end
      end
    end
  end
end
