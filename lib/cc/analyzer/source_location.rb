module CC
  module Analyzer
    class SourceLocation

      def initialize(source_buffer, source_range)
        @source_buffer = source_buffer
        @source_range = source_range
      end

      def path
        @source_buffer.name
      end

      def line
        decomposed_begin.first
      end

      def column
        decomposed_begin.last
      end

      def begin_pos
        @source_range.begin_pos
      end

      def end_pos
        @source_range.end_pos
      end

      def as_json
        {
          begin: {
            line: decomposed_begin.first,
            pos: @source_range.begin_pos
          },
          end: {
            line: decomposed_end.first,
            pos: @source_range.end_pos
          }
        }
      end

    private

      def decomposed_begin
        @decomposed_begin ||= @source_buffer.decompose_position(@source_range.begin_pos)
      end

      def decomposed_end
        @decomposed_end ||= @source_buffer.decompose_position(@source_range.end_pos)
      end

    end
  end
end
