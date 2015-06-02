module CC
  module Analyzer
    class AnalysisResult
      attr_reader :source_buffer

      def initialize(source_buffer, document)
        @source_buffer = source_buffer
        @document = document
      end

      def definitions
        @definitions ||= Array.wrap(@document["definitions"]).map do |doc|
          Definition.from_hash(source_buffer, doc)
        end
      end

      def issues
        @issues ||= Array.wrap(@document["issues"]).map do |doc|
          Issue.from_hash(source_buffer, doc)
        end
      end

    end
  end
end
