module CC
  module Analyzer
    class LocationDescription
      def initialize(location)
        @location = location
      end

      def to_s
        str = ""
        if location["lines"]
          str << location["lines"]["begin"].to_s

          if location["lines"]["end"]
            str << "-#{location["lines"]["end"]}"
          end
        elsif positions = location["positions"]
          if positions["begin"]["line"]
            str << positions["begin"]["line"].to_s
            if positions["begin"]["column"]
              str << ":#{positions["begin"]["column"]}"
            end
          elsif positions["begin"]["offset"]
            str << positions["begin"]["offset"].to_s
          end

          if ending = positions["end"]
            str << "-"
            if ending["line"]
              str << ending["line"].to_s
              if ending["column"]
                str << ":#{ending["column"]}"
              end
            elsif ending["offset"]
              str << ending["offset"].to_s
            end
          end
        end
        str
      end

      private

      attr_reader :location
    end
  end
end
