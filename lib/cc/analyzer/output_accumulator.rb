module CC
  module Analyzer
    class OutputAccumulator
      attr_accessor :output

      def initialize
        @output = ""
      end

      def write(data)
        output << data
      end
    end
  end
end
