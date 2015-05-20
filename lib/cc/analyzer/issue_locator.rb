module CC
  module Analyzer
    class IssueLocator

      def initialize(definitions)
        @definitions = definitions
      end

      def definition_at(position)
        sorted_definitions.detect do |definition|
          definition.begin_pos <= position &&
          definition.end_pos >= position
        end
      end

    private

      def sorted_definitions
        @sorted_definitions ||= @definitions.sort_by(&:begin_pos).reverse
      end

    end
  end
end
