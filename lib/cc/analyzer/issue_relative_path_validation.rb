module CC
  module Analyzer
    class IssueRelativePathValidation < Validation
      def valid?
        path && !path.start_with?("/")
      end

      def message
        "Path must be relative"
      end

      private

      def path
        object.fetch("location", {})["path"]
      end
    end
  end
end
