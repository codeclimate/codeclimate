module CC
  class Workspace
    class Exclusions
      attr_reader :exclude_paths

      def initialize(exclude_paths)
        @exclude_paths = exclude_paths.map { |p| normalize(p) }.compact
      end

      def glob?(exclusion)
        exclusion.include?("*")
      end

      def expanded_glob(exclusion)
        Dir.glob(exclusion)
      end

      private

      def normalize(pattern)
        pattern.to_s.sub(%r{/\*\*(/\*)?$}, "")
      end
    end
  end
end
