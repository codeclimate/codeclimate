module CC
  module Analyzer
    class Issue

      def self.from_hash(source_buffer, doc)
        IssueAdapter.new(source_buffer, doc).to_issue
      end

      attr_reader :description
      attr_reader :location
      attr_reader :fingerprint
      attr_reader :attrs
      attr_reader :remediation_points
      attr_reader :check
      attr_reader :categories

      def initialize(check, description, location, fingerprint, categories, remediation_points = 1_000, attrs = {})
        @check = check
        @description = description
        @location = location
        @fingerprint = fingerprint
        @categories = categories
        @remediation_points = remediation_points
        @attrs = attrs
      end

      def begin_pos
        location.begin_pos
      end

      def as_json
        {
          categories: categories,
          check: check,
          fingerprint: fingerprint,
          location: location.as_json,
          description: description,
          remediation_points: remediation_points,
        }
      end

    end
  end
end
