module CC
  module Analyzer
    class IssueDescriptionPresenceValidation < Validation
      def valid?
        object["description"].present?
      end

      def message
        "Description must be present"
      end
    end
  end
end
