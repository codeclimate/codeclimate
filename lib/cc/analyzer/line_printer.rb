require "active_support"
require "active_support/core_ext"

module CC
  module Analyzer
    # LinePrinter receives a stream of content (e.g. from a subprocess) and
    # prints it line-by-line to an IO steam, with each line prefixed
    class LinePrinter
      class Null
        def <<(string)
        end

        def close
        end
      end

      def initialize(output, prefix)
        @output = output
        @prefix = prefix
        @buffer = ""
      end

      def <<(string)
        @buffer << string

        # Find completed lines (ending in newlines)
        while !(newline_location = @buffer.index("\n")).nil?
          print_line(@buffer[0..newline_location])

          # Remove the printed content from the buffer
          @buffer = @buffer[(newline_location + 1)..-1]
        end
      end

      def close
        # Since we don't print a line until we receive its newline, there could
        # be unprinted content at the end
        print_line(@buffer + "\n") unless @buffer.blank?
      end

    private

      def print_line(content)
        @output.print(@prefix + content)
      end

    end
  end
end
