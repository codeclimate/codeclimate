module CC
  module Analyzer
    class Filesystem

      def initialize(root)
        @root = root
      end

      def exist?(path)
        File.exist?(path_for(path))
      end

      def source_buffer_for(path)
        SourceBuffer.new(path, read_path(path))
      end

      def read_path(path)
        File.read(path_for(path))
      end

      def file_paths
        Dir.chdir(@root) do
          Dir["**/*.*"].sort.select { |path| File.file?(path) }
        end
      end

      def files_matching(globs)
        Dir.chdir(@root) do
          globs.map do |glob|
            Dir.glob(glob)
          end.flatten.sort.uniq
        end
      end

      def path_for(path)
        File.join(@root, path)
      end
    end
  end
end
