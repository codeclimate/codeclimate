module CC
  module Analyzer
    class IssueValidator
      CHECKS = [
        IssueCategoryValidation,
        IssueCheckNamePresenceValidation,
        IssuePathPresenceValidation,
        IssueRelativePathValidation,
        IssueTypeValidation,
      ].freeze

      attr_reader :error

      def initialize(issue)
        @issue = issue
      end

      def valid?
        @error.blank?
      end

      def validate
        if issue && invalid_messages.any?
          @error = {
            message: "#{invalid_messages.join(", ")}: `#{issue}`.",
            issue: issue,
          }
          false
        else
          true
        end
      end

      private

      attr_reader :issue

      def invalid_messages
        @invalid_messages ||= CHECKS.each_with_object([]) do |check, result|
          validator = check.new(issue)
          result << validator.message unless validator.valid?
          CLI.debug("#{check} #{validator.valid?}")
        end
      end
    end
  end
end
