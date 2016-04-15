module CC
  module Analyzer
    class IssuePathPresenceValidation < Validation
      def valid?
        path.present?
      end

      def message
        "Path must be present"
      end

      private

      def path
        object.fetch("location", {})["path"]
      end
    end
  end
end
