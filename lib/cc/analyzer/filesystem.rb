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

      def any?(&block)
        file_paths.any?(&block)
      end

      def files_matching(globs)
        Dir.chdir(@root) do
          globs.map do |glob|
            Dir.glob(glob)
          end.flatten.sort.uniq
        end
      end

      private

      def file_paths
        @file_paths ||= Dir.chdir(@root) do
          `find . -type f -print0`.strip.split("\0").map do |path|
            path.sub(/^\.//, "")
          end
        end
      end

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
