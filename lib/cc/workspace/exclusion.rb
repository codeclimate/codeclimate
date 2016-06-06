module CC
  class Workspace
    class Exclusion
      def initialize(pattern)
        @negated = pattern.starts_with?("!")
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

      def negated?
        negated
      end

      private

      attr_reader :negated, :pattern

      def simplify(pattern)
        pattern.to_s.sub(%r{(/\*\*)?(/\*)?$}, "").sub(/^\!/, "")
      end
    end
  end
end
