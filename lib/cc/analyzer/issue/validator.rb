module CC
  module Analyzer
    class Issue
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

        def engine_output_error
          CC::Analyzer::Engine::IssueInvalid.new(
            @error[:message],
            output: @error[:message], issue: @error[:issue],
          )
        end

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
