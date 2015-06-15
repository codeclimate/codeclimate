module CC
  module Analyzer
    class LocationDescription
      def initialize(location)
        @location = location
      end

      def to_s
        str = ""
        if location["lines"]
          str << render_lines
        elsif positions = location["positions"]
          str << render_position(positions["begin"])

          if positions["end"]
            str << "-"
            str << render_position(positions["end"])
          end
        end
        str
      end

      private

      attr_reader :location

      def render_lines
        str = location["lines"]["begin"].to_s
        str << "-#{location["lines"]["end"]}" if location["lines"]["end"]
        str
      end

      def render_position(position)
        str = ""

        if position["line"]
          str << position["line"].to_s
          str << ":#{position["column"]}" if position["column"]
        elsif position["offset"]
          str << position["offset"].to_s
        end

        str
      end
    end
  end
end
