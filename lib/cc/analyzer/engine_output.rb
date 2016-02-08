module CC
  module Analyzer
    class EngineOutput
      delegate :blank?, to: :chomped_output
      delegate :to_json, to: :as_issue

      def initialize(raw_output)
        @raw_output = raw_output
      end

      def issue?
        parsed_output &&
          parsed_output["type"].present? &&
          parsed_output["type"].downcase == "issue"
      end

      def as_issue
        Issue.new(raw_output)
      end

      private

      attr_accessor :raw_output

      def parsed_output
        JSON.parse(chomped_output)
      rescue JSON::ParserError
        nil
      end

      # Docker can put start-of-text characters when logging,
      # which show up as issues. Remove them here if they are at either end
      # of the output and then check blankness.
      # https://github.com/docker/docker/issues/7375
      def chomped_output
        @chomped_output ||= raw_output.chomp("\u0002")
      end
    end
  end
end
