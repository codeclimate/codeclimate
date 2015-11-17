require "file_utils_ext"
require "cc/analyzer/path_minimizer"
require "cc/analyzer/path_filter"

module CC
  module Analyzer
    class IncludePathsBuilder
      IGNORE_PATHS = [".", "..", ".git"].freeze

      attr_reader :cc_include_paths

      def initialize(cc_exclude_paths, cc_include_paths = [])
        @cc_exclude_paths = cc_exclude_paths
        @cc_include_paths = cc_include_paths
      end

      def build
        PathMinimizer.new(paths_filter.paths).minimize.uniq
      end

      private

      def paths_filter
        @_paths =
          PathFilter.new(include_paths).
          reject_paths(ignored_files).
          raise_if_any_unreadable_files.
          reject_unreadable_paths.
          select_readable_files.
          reject_symlinks
      end

      def include_paths
        if @cc_include_paths.empty?
          all_paths
        else
          @cc_include_paths.flat_map do |path|
            PathEntries.new(path).entries
          end
        end
      end

      def all_paths
        Dir.glob("*", File::FNM_DOTMATCH).
          reject { |path| IncludePathsBuilder::IGNORE_PATHS.include?(path) }.
          flat_map { |path| PathEntries.new(path).entries }
      end

      def ignored_files
        return @_ignored_files if @_ignored_files

        Tempfile.open(".cc_gitignore") do |tmp|
          tmp.write(File.read(".gitignore")) if File.file?(".gitignore")
          tmp << @cc_exclude_paths.join("\n")
          tmp.close
          tracked_and_ignored = `git ls-files -zi -X #{tmp.path} 2>/dev/null`.split("\0")
          untracked_and_ignored = `git ls-files -zio -X #{tmp.path} 2>/dev/null`.split("\0")
          @_ignored_files = tracked_and_ignored + untracked_and_ignored
        end
      end
    end
  end
end
