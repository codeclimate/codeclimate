module CC
  module Analyzer
    class Filesystem

      def initialize(root)
        @root = root
      end

      def exist?(path)
        File.exist?(File.join(@root, path))
      end

      def source_buffer_for(path)
        SourceBuffer.new(path, read_path(path))
      end

      def read_path(path)
        File.read(File.join(@root, path))
      end

      def file_paths
        Dir.chdir(@root) do
          Dir["**/*.*"].sort.select { |path| File.file?(path) }
        end
      end

    end
  end
end
