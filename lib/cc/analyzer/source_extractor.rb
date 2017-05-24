module CC
  module Analyzer
    class SourceExtractor
      InvalidLocation = Class.new(StandardError)

      def initialize(source)
        @source = source
      end

      def extract(location)
        validate_location(location)

        if (lines = location["lines"])
          extract_from_lines(lines)
        elsif (positions = location["positions"])
          extract_from_positions(positions)
        end
      end

      private

      attr_reader :source

      def validate_location(location)
        validator = IssueValidations::LocationFormatValidation::Validator.new(location)
        unless validator.valid?
          raise InvalidLocation, validator.message
        end
      end

      def extract_from_lines(lines)
        begin_index = lines.fetch("begin") - 1
        end_index = lines.fetch("end") - 1
        range = (begin_index..end_index)

        source.each_line.with_object("").with_index do |(source_line, memo), index|
          memo << source_line if range.include?(index)
        end
      end

      def extract_from_positions(positions)
        positions = convert_to_offsets(positions)
        begin_offset = positions.fetch("begin").fetch("offset")
        end_offset = positions.fetch("end").fetch("offset")
        length = end_offset - begin_offset

        source[begin_offset, length + 1]
      end

      def convert_to_offsets(positions)
        positions.each_with_object({}) do |(key, value), memo|
          memo[key] =
            if value.key?("offset")
              value
            else
              {
                "offset" => to_offset(value["line"] - 1, value["column"] - 1),
              }
            end
        end
      end

      def to_offset(line, column, offset = 0)
        source.each_line.with_index do |source_line, index|
          offset +=
            if line == index
              column
            else
              source_line.length
            end

          break if index >= line
        end

        offset
      end
    end
  end
end
