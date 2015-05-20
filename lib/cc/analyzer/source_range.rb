module CC
  module Analyzer
    class SourceRange
      attr_reader :begin_pos
      attr_reader :end_pos

      def initialize(begin_pos, end_pos)
        @begin_pos = begin_pos
        @end_pos = end_pos
      end

    end
  end
end
