module CC
  module Analyzer
    class Issue
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

      def initialize(output)
        @output = output
      end

      def as_json(*)
        parsed_output.reverse_merge!(
          "fingerprint" => fingerprint,
        )
      end

      def fingerprint
        parsed_output.fetch("fingerprint", default_fingerprint)
      end

      # Allow access to hash keys as methods
      SPEC_ISSUE_ATTRIBUTES.each do |key|
        define_method(key) do
          parsed_output[key]
        end
      end

      private

      attr_reader :output

      def default_fingerprint
        digest = Digest::MD5.new
        digest << path
        digest << "|"
        digest << check_name.to_s
        digest.to_s
      end

      def parsed_output
        @parsed_output ||= JSON.parse(output)
      end

      def path
        parsed_output.fetch("location", {}).fetch("path", "")
      end
    end
  end
end
