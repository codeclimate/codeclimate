module CC
  module Analyzer
    class Issue

      def self.from_hash(source_buffer, doc)
        IssueAdapter.new(source_buffer, doc).to_issue
      end

      attr_reader :message
      attr_reader :location
      attr_reader :fingerprint
      attr_reader :attrs
      attr_reader :remediation_points
      attr_reader :check

      def initialize(check, message, location, fingerprint, remediation_points = 1_000, attrs = {})
        @check = check
        @message = message
        @location = location
        @fingerprint = fingerprint
        @remediation_points = remediation_points
        @attrs = attrs
      end

      def begin_pos
        location.begin_pos
      end

      def as_json
        {
          check: check,
          fingerprint: fingerprint,
          location: location.as_json,
          message: message,
          remediation_points: remediation_points,
        }
      end

    end
  end
end
