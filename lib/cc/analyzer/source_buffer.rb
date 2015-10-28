# Adapted from https://github.com/whitequark/parser/blob/master/lib/parser/source/buffer.rb
module CC
  module Analyzer
    class SourceBuffer
      attr_reader :name
      attr_reader :source

      def initialize(name, source)
        @name = name
        @source = source
      end

      def decompose_position(position)
        line_no, line_begin = line_for(position)

        [1 + line_no, position - line_begin]
      end

      def line_count
        @source.lines.count
      end

      private

      def line_for(position)
        line_begins.bsearch do |_, line_begin|
          line_begin <= position
        end
      end

      def line_begins
        unless @line_begins
          @line_begins = [[0, 0]]
          index = 1

          @source.each_char do |char|
            @line_begins.unshift [@line_begins.length, index] if char == "\n"

            index += 1
          end
        end

        @line_begins
      end
    end
  end
end
