module CC
  module Analyzer
    class EngineOutput
      delegate :blank?, to: :raw_output

      def initialize(name, raw_output)
        @name = name
        @raw_output = raw_output
      end

      def issue?
        valid_with_type?("issue")
      end

      def measurement?
        valid_with_type?("measurement")
      end

      def as_issue
        Issue.new(name, raw_output)
      end

      def to_json
        if issue?
          as_issue.to_json
        elsif measurement?
          Measurement.new(name, raw_output).to_json
        end
      end

      def valid?
        valid_json? && validator && validator.valid?
      end

      def error
        if !valid_json?
          { message: "Invalid JSON", output: raw_output }
        elsif !validator.present?
          { message: "Unsupported document type", output: raw_output }
        else
          validator.error
        end
      end

      private

      attr_accessor :name, :raw_output

      def valid_json?
        parsed_output.present?
      end

      def valid_with_type?(type)
        parsed_output &&
          parsed_output["type"].present? &&
          parsed_output["type"].downcase == type
      end

      def parsed_output
        @parsed_output ||= JSON.parse(raw_output)
      rescue JSON::ParserError
        nil
      end

      def validator
        if issue?
          IssueValidator.new(parsed_output)
        elsif measurement?
          MeasurementValidator.new(parsed_output)
        end
      end
    end
  end
end
