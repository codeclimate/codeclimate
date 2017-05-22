module CC
  module Analyzer
    class EngineOutputFilter
      ISSUE_TYPE = "issue".freeze

      def initialize(config = {})
        @config = config
      end

      def filter?(output)
        output.blank? || (output.issue? && ignore_issue?(output.as_issue))
      end

      private

      def ignore_issue?(issue)
        check_disabled?(issue) || ignore_fingerprint?(issue)
      end

      def check_disabled?(issue)
        !check_config(issue.check_name).fetch("enabled", true)
      end

      def ignore_fingerprint?(issue)
        @config.fetch("exclude_fingerprints", []).include?(issue.fingerprint)
      rescue SourceExtractor::InvalidLocation
        false
      end

      def check_config(check_name)
        @checks ||= @config.fetch("checks", {})
        @checks.fetch(check_name, {})
      end
    end
  end
end
