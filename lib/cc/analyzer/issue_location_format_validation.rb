module CC
  module Analyzer
    class IssueLocationFormatValidation < Validation
      def valid?
        if location["lines"]
          valid_lines?(location["lines"])
        elsif location["positions"]
          valid_positions?(location["positions"])
        else
          false
        end
      end

      def message
        "Location is not formatted correctly"
      end

      private

      def location
        @location ||= object.fetch("location", {})
      end

      def valid_positions?(positions)
        positions.is_a?(Hash) &&
          valid_position?(positions["begin"]) &&
          valid_position?(positions["end"])
      end

      def valid_position?(position)
        position &&
          (
            (position["line"] && position["column"]) ||
            position["offset"]
          )
      end

      def valid_lines?(lines)
        lines.is_a?(Hash) && lines.key?("begin") && lines.key?("end")
      end
    end
  end
end
