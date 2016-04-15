module CC
  module Analyzer
    class IssueTypeValidation < Validation
      def valid?
        type && type.casecmp("issue").zero?
      end

      def message
        "Type must be 'issue' but was '#{type}'"
      end

      private

      def type
        object["type"]
      end
    end
  end
end
