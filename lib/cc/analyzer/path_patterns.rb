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
          @patterns.flat_map do |pattern|
            # FIXME: there exists a temporary workaround whereby **-style globs
            # are translated to **/*-style globs within cc-yaml's custom
            # Glob#value method. It was thought that that would work correctly
            # with Dir.glob but it turns out we have to actually invoke #value
            # directory for this to work. We need to guard this on class (not
            # respond_to?) because our mocking framework adds a #value method to
            # all objects, apparently.
            if pattern.is_a?(CC::Yaml::Nodes::Glob)
              value = pattern.value
            else
              value = pattern
            end

            Dir.glob(value)
          end
        end

        results.sort.uniq
      end
    end
  end
end
