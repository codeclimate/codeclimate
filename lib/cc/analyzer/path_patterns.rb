module CC
  module Analyzer
    class PathPatterns
      def initialize(patterns, root = Dir.pwd)
        @patterns = patterns
        @root = root
      end

      def expanded
        @expanded ||= expand
      end

      private

      def expand
        results = Dir.chdir(@root) do
          @patterns.map do |pattern|
            Dir.glob(pattern)
          end
        end

        results.flatten.sort.uniq
      end
    end
  end
end
