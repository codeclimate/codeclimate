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

      def write_path(path, content)
        File.write(path_for(path), content)
        File.chown(root_uid, root_gid, path_for(path))
      end

      def file_paths
        Dir.chdir(@root) do
          Dir["**/*.*"].select { |path| File.file?(path) }.sort
        end
      end

      def all
        @files ||= Dir.chdir(@root) { Dir.glob("**/*") }
      end

      def any?(&block)
        all.any?(&block)
      end

      def files_matching(globs)
        Dir.chdir(@root) do
          globs.map do |glob|
            Dir.glob(glob)
          end.flatten.sort.uniq
        end
      end

      private

      def path_for(path)
        File.join(@root, path)
      end

      def root_uid
        root_stat.uid
      end

      def root_gid
        root_stat.gid
      end

      def root_stat
        @root_stat ||= File.stat(@root)
      end
    end
  end
end
