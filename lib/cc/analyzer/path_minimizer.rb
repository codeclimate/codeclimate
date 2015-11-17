require "cc/analyzer/path_entries"
require "cc/analyzer/include_paths_builder"

module CC
  module Analyzer
    class PathMinimizer
      def initialize(paths)
        @paths = paths
        @to_remove = []
      end

      def minimize
        if diff.empty?
          ["./"]
        else
          filtered_paths
        end
      end

      private

      attr_reader :paths

      def diff
        @_diff ||=
          (all_files - paths).
          reject { |path| File.symlink?(path) }.
          flat_map { |path| build_entry_combinations(path) }
      end

      def filtered_paths
        filtered_paths = @paths - paths_to_remove
        filtered_paths.map { |path| add_trailing_slash(path) }
      end

      def paths_to_remove
        @paths.reduce([]) do |to_remove, path|
          if File.directory?(path)
            to_remove + removable_paths_for(path)
          else
            to_remove
          end
        end
      end

      def removable_paths_for(path)
        file_paths = PathEntries.new(path).entries

        if all_paths_match?(file_paths)
          file_paths - [path]
        else
          [path]
        end
      end

      def all_paths_match?(paths)
        paths.all? { |path| @paths.include?(path) }
      end

      def add_trailing_slash(path)
        if File.directory?(path) && !path.end_with?("/")
          "#{path}/"
        else
          path
        end
      end

      def build_entry_combinations(path)
        split = path.split("/")

        0.upto(split.length - 1).map do |n|
          split[0..n].join("/")
        end
      end

      def all_files
        @_all_files ||=
          Dir.glob("*", File::FNM_DOTMATCH).
          reject { |path| IncludePathsBuilder::IGNORE_PATHS.include?(path) }.
          flat_map { |path| PathEntries.new(path).entries }
      end
    end
  end
end
