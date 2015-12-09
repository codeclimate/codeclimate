module CC
  module Analyzer
    class Issue
      autoload :Adapter, "cc/analyzer/issue/adapter"
      autoload :Builder, "cc/analyzer/issue/builder"
      autoload :Validations, "cc/analyzer/issue/validations"
      autoload :Validator, "cc/analyzer/issue/validator"

      POINTS_PER_COST = 1_000_000.0

      def self.path(raw_smell_document)
        raw_smell_document.fetch(:location, {}).fetch(:path, nil)
      end

      def initialize(raw_smell_document)
        @raw_smell_document = raw_smell_document
      end

      def fingerprint
        @raw_smell_document[:fingerprint]
      end

      def path
        self.class.path(@raw_smell_document)
      end

      def path_exists?
        File.exist?(path)
      end

      def remediation_cost
        remediation_points / POINTS_PER_COST
      end

      def remediation_points
        @raw_smell_document[:remediation_points]
      end

      def smell_document
        @raw_smell_document.merge(remediation_cost: remediation_cost)
      end
    end
  end
end
