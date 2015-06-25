module CC
  module Analyzer
    class LocationDescription
      def initialize(location, suffix = "")
        @location = location
        @suffix = suffix
      end

      def to_s
        str = ""

        if location["lines"]
          str << render_lines
        elsif (positions = location["positions"])
          str << render_position(positions["begin"])

          if positions["end"]
            str << "-"
            str << render_position(positions["end"])
          end
        end

        str << suffix unless str.blank?

        str
      end

      private

      attr_reader :location, :suffix

      def render_lines
        str = location["lines"]["begin"].to_s

        if location["lines"]["end"] && location["lines"]["end"] != location["lines"]["begin"]
          str << "-#{location["lines"]["end"]}"
        end

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
