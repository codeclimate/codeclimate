module CC
  module Analyzer
    class IssueValidator
      CHECKS = [
        IssueCategoryValidation,
        IssueCheckNamePresenceValidation,
        IssueDescriptionPresenceValidation,
        IssuePathExistenceValidation,
        IssuePathPresenceValidation,
        IssueRelativePathValidation,
        IssueTypeValidation,
      ].freeze

      attr_reader :error

      def initialize(issue)
        @issue = issue
      end

      def valid?
        return @valid unless @valid.nil?

        if issue && invalid_messages.any?
          @error = {
            message: "#{invalid_messages.join("; ")}: `#{issue}`.",
            issue: issue,
          }
          @valid = false
        else
          @valid = true
        end
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
