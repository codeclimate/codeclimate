module CC
  module Analyzer
    class Accumulator
      def initialize(delimiter)
        @delimiter = delimiter
        @buffer = ""
      end

      def on_flush(&block)
        @on_flush = block
      end

      def <<(data)
        while data && data.include?(@delimiter)
          chunk, data = data.split(@delimiter, 2)

          @on_flush.call("#{@buffer}#{chunk}")
          @buffer = ""
        end

        @buffer << data if data
      end
    end
  end
end

