module CC
  class Workspace
    class Exclusion
      def initialize(pattern)
        @original_pattern = pattern
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

      def remover?
        !original_pattern.start_with?("!")
      end

      private

      attr_reader :original_pattern, :pattern

      def simplify(pattern)
        pattern.to_s.sub(%r{(/\*\*)?(/\*)?$}, "").sub(/^\!/, '')
      end
    end
  end
end
