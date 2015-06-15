module CC
  module Analyzer
    class IssueSorter
      def initialize(issues)
        @issues = issues
      end

      def by_location
        @issues.sort_by { |i| line_or_offset(i) }
      end

      private

      def line_or_offset(issue)
        location = issue["location"]

        case
        when location["lines"]
          location["lines"]["begin"]
        when location["positions"] && location["positions"]["begin"]["line"]
          location["positions"]["begin"]["line"] + location["positions"]["begin"]["column"].to_i
        when location["positions"] && location["positions"]["begin"]["offset"]
          location["positions"]["begin"]["offset"] + 1_000_000 # push offsets to end of list
        else
          0 # whole-file issues are first
        end
      end
    end
  end
end
