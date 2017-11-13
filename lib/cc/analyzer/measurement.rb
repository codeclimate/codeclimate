module CC
  module Analyzer
    class Measurement
      def initialize(engine_name, output)
        @engine_name = engine_name
        @output = output
      end

      def as_json(*)
        parsed_output.merge("engine_name" => engine_name)
      end

      private

      attr_reader :engine_name, :output

      def parsed_output
        @parsed_output ||= JSON.parse(output)
      end
    end
  end
end
