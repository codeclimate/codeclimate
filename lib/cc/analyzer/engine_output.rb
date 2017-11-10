module CC
  module Analyzer
    class EngineOutput
      delegate :blank?, to: :raw_output
      delegate :to_json, to: :as_issue

      def initialize(name, raw_output)
        @name = name
        @raw_output = raw_output
      end

      def issue?
        parsed_output &&
          parsed_output["type"].present? &&
          parsed_output["type"].downcase == "issue"
      end

      def as_issue
        Issue.new(name, raw_output)
      end

      def valid?
        valid_json? && validator.valid?
      end

      def error
        if valid_json?
          validator.error
        else
          { message: "Invalid JSON: #{raw_output}" }
        end
      end

      private

      attr_accessor :name, :raw_output

      def valid_json?
        parsed_output.present?
      end

      def parsed_output
        @parsed_output ||= JSON.parse(raw_output)
      rescue JSON::ParserError
        nil
      end

      def validator
        IssueValidator.new(parsed_output)
      end
    end
  end
end
