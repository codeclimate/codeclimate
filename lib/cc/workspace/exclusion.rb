module CC
  class Workspace
    class Exclusion
      def initialize(pattern)
        @pattern = simplify(pattern)
      end

      def expand
        if glob?
          Dir.glob(pattern)
        else
          [pattern]
        end
      end

      def glob?
        pattern.include?("*")
      end

      private

      attr_reader :pattern

      def simplify(pattern)
        pattern.to_s.sub(%r{(/\*\*)?(/\*)?$}, "")
      end
    end
  end
end
