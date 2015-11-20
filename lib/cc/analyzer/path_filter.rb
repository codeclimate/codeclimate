module CC
  module Analyzer
    class PathFilter
      attr_reader :paths

      def initialize(paths)
        @paths = paths
      end

      def reject_unreadable_paths
        @paths = paths - unreadable_path_entries
        self
      end

      def reject_paths(ignore_paths)
        @paths = paths - ignore_paths
        self
      end

      def select_readable_files
        @paths = paths.select { |path| File.exist?(path) && FileUtils.readable_by_all?(path) }
        self
      end

      def reject_symlinks
        @paths = paths.reject { |path| File.symlink?(path) }
        self
      end

      def reject_globs(globs)
        patterns = PathPatterns.new(globs)
        @paths = paths.reject { |path| patterns.match?(pathpatterns.match?(path)) }
        self
      end

      private

      def unreadable_path_entries
        @_unreadable_path_entries ||=
          unreadable_paths.flat_map { |path| PathEntries.new(path).entries }
      end

      def unreadable_paths
        paths.select do |path|
          File.directory?(path) && !FileUtils.readable_by_all?(path)
        end
      end
    end
  end
end
