require "file_utils_ext"
require "cc/analyzer/path_minimizer"

module CC
  module Analyzer
    class IncludePathsBuilder
      IGNORE_PATHS = [".", "..", ".git"].freeze

      attr_reader :cc_include_paths

      def initialize(cc_exclude_paths, cc_include_paths = [])
        @cc_exclude_paths = cc_exclude_paths
        @cc_include_paths = cc_include_paths
      end

      def build(extra_excludes = [])
        if extra_excludes.empty?
          build_without_extra_excludes
        else
          build_with_extra_excludes(extra_excludes)
        end
      end

      private

      def build_without_extra_excludes
        @_build_without_extra_excludes ||= PathMinimizer.new(paths).minimize
      end

      def build_with_extra_excludes(excludes)
        new_paths = paths.reject { |path| matches_globs?(path, excludes) }
        PathMinimizer.new(new_paths).minimize
      end

      def paths
        @_paths ||=
          all_matching_paths.
          reject { |f| ignored_files.include?(f) }.
          each { |f| raise_if_unreadable(f) }.
          select { |f| FileUtils.readable_by_all?(f) }.
          reject { |f| File.symlink?(f) }
      end

      def all_matching_paths
        include_paths.reject do |path|
          matches_exclude?(path) || File.symlink?(path)
        end
      end

      def include_paths
        if @cc_include_paths.empty?
          Dir.glob("**/*", File::FNM_DOTMATCH)
        else
          @cc_include_paths.map do |path|
            glob_or_include_path(path)
          end.flatten
        end
      end

      def glob_or_include_path(path)
        if File.directory?(path)
          paths = Dir.glob("#{path}/**/*", File::FNM_DOTMATCH) - ["#{path}/."]
          paths.push(path)
        else
          path
        end
      end

      def matches_exclude?(path)
        matches_globs?(path, @cc_exclude_paths)
      end

      def matches_globs?(path, globs)
        globs.any? do |exclude_path|
          File.fnmatch(exclude_path, path)
        end
      end

      def raise_if_unreadable(path)
        if !File.directory?(path) && !FileUtils.readable_by_all?(path)
          raise CC::Analyzer::UnreadableFileError, "Can't read #{path}"
        end
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
