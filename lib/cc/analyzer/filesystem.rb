module CC
  module Analyzer
    class Filesystem
      attr_reader :root

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

      def ls
        Dir.entries(root).reject { |entry| [".", ".."].include?(entry) }
      end

      private

      def path_for(path)
        File.join(root, path)
      end

      def root_uid
        root_stat.uid
      end

      def root_gid
        root_stat.gid
      end

      def root_stat
        @root_stat ||= File.stat(root)
      end
    end
  end
end
