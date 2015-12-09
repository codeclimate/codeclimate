module CC
  module Analyzer
    class EngineOutputFilter
      ISSUE_TYPE = "issue".freeze

      def initialize(config = {})
        @config = config
      end

      def filter?(output)
        return true unless output.present?

        builder = Issue::Builder.new(output).tap(&:run)
        raise builder.error if builder.error

        ignore_issue?(builder.issue)
      end

      private

      def ignore_issue?(issue)
        check_disabled?(issue) || ignore_fingerprint?(issue)
      end

      def check_disabled?(issue)
        !check_config(issue[:check_name]).fetch("enabled", true)
      end

      def ignore_fingerprint?(issue)
        if (fingerprint = issue[:fingerprint])
          @config.fetch("exclude_fingerprints", []).include?(fingerprint)
        else
          false
        end
      end

      def check_config(check_name)
        @checks ||= @config.fetch("checks", {})
        @checks.fetch(check_name, {})
      end
    end
  end
end
