module CC
  module Analyzer
    class EngineOutputOverrider
      def initialize(config = {})
        @config = config
      end

      def apply(output)
        if output.issue?
          override_severity(output.as_issue.as_json)
        else
          output
        end
      end

      private

      attr_reader :config

      def override_severity(issue)
        issue.merge(override("severity"))
      end

      def override(name)
        config.
          fetch("issue_override", {}).
          slice(name)
      end
    end
  end
end
