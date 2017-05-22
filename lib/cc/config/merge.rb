module CC
  class Config
    class Merge
      def initialize(left, right)
        @left = left
        @right = right
      end

      def run
        Config.new(
          analysis_paths: analysis_paths,
          development: development?,
          engines: engines,
          exclude_patterns: exclude_patterns,
          prepare: prepare,
        )
      end

      private

      attr_reader :left, :right

      def analysis_paths
        left.analysis_paths | right.analysis_paths
      end

      def development?
        [left.development?, right.development?].any?
      end

      def engines
        Engines.new(left.engines, right.engines).run
      end

      def exclude_patterns
        left.exclude_patterns | right.exclude_patterns
      end

      def prepare
        left.prepare.merge(right.prepare)
      end

      class Engines
        def initialize(left, right)
          @left = left
          @right = right
        end

        def run
          left.to_a.concat(right.to_a).group_by(&:hash).map do |hash, engines|
            engines.first.merge(engines.last)
          end.to_set
        end

        private

        attr_reader :left, :right
      end
    end
  end
end
