module CC
  class Workspace
    class PathsValidator
      def initialize(paths)
        @paths = paths
        @root = Dir.pwd
      end

      def run
        paths.each do |path|
          unless valid?(path)
            raise ArgumentError, invalid_path_error(path)
          end
        end
      end

      private

      attr_reader :paths, :root

      def valid?(path)
        File.expand_path(path).sub(/^#{root}\//, "") == path
      end

      def invalid_path_error(path)
        "Invalid path argument #{path.inspect}. " \
          "Must be relative to the project root, without any ./ prefix. " \
          "To analyze the entire project, don't specify any paths."
      end
    end
  end
end
