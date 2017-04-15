module CC
  module Analyzer
    class Issue
      DEFAULT_SEVERITY = IssueValidations::SeverityValidation::MINOR
      DEPRECATED_SEVERITY = IssueValidations::SeverityValidation::NORMAL

      SPEC_ISSUE_ATTRIBUTES = %w[
        categories
        check_name
        content
        description
        location
        other_locations
        remediation_points
        severity
        type
      ]

      def initialize(engine_name, output)
        @engine_name = engine_name
        @output = output
      end

      def as_json(*)
        parsed_output.reverse_merge!(
          "engine_name" => engine_name,
          "fingerprint" => fingerprint,
        ).merge!("severity" => severity)
      end

      def fingerprint
        parsed_output.fetch("fingerprint") { default_fingerprint }
      end

      # Allow access to hash keys as methods
      SPEC_ISSUE_ATTRIBUTES.each do |key|
        define_method(key) do
          parsed_output[key]
        end
      end

      def path
        parsed_output.fetch("location", {}).fetch("path", "")
      end

      private

      attr_reader :engine_name, :output

      def default_fingerprint
        SourceFingerprint.new(self).compute
      end

      def severity
        severity = parsed_output.fetch("severity", DEFAULT_SEVERITY)

        if severity == DEPRECATED_SEVERITY
          DEFAULT_SEVERITY
        else
          severity
        end
      end

      def parsed_output
        @parsed_output ||= JSON.parse(output)
      end
    end
  end
end
