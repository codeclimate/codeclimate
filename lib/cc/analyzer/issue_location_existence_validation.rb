module CC
  module Analyzer
    class IssueLocationExistenceValidation < Validation
      def valid?
        if location["lines"]
          valid_lines?
        elsif location["positions"]
          location["positions"].is_a?(Hash) &&
            valid_position?(location["positions"]["begin"]) &&
            valid_position?(location["positions"]["end"])
        else
          false
        end
      end

      def message
        "Location does not exist in the file"
      end

      private

      def location
        object.fetch("location", {})
      end

      def contents
        @contents ||= location["path"] && File.read(location["path"])
      end

      def lines
        @lines ||= contents.lines
      end

      def valid_lines?
        start = location["lines"]["begin"]
        stop = location["lines"]["end"]

        start && stop && valid_line?(start) && valid_line?(stop)
      end

      def valid_position?(position)
        (position["offset"] && valid_offset?(position["offset"])) ||
          (position["line"] && position["column"] && valid_linecol?(position["line"], position["column"]))
      end

      def valid_offset?(offset)
        !contents[offset].nil?
      end

      def valid_line?(line)
        !lines[line - 1].nil?
      end

      def valid_linecol?(line, column)
        (text = lines[line - 1]) && !text[column - 1].nil?
      end
    end
  end
end
