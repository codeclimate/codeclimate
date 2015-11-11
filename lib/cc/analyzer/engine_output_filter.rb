module CC
  module Analyzer
    class EngineOutputFilter
      ISSUE_TYPE = "issue".freeze

      def initialize(config = {})
        @config = config
      end

      def filter?(output)
        return true unless output.present?

        if (json = parse_as_json(output))
          issue?(json) && ignore_issue?(json)
        else
          false
        end
      end

      private

      def parse_as_json(output)
        JSON.parse(output)
      rescue JSON::ParserError
        nil
      end

      def issue?(json)
        json["type"] && json["type"].downcase == ISSUE_TYPE
      end

      def ignore_issue?(json)
        check_disabled?(json) || ignore_fingerprint?(json)
      end

      def check_disabled?(json)
        !check_config(json["check_name"]).fetch("enabled", true)
      end

      def ignore_fingerprint?(json)
        if (fingerprint = json["fingerprint"])
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
