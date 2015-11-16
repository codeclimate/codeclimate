module CC
  module Analyzer
    class PathMinimizer
      def initialize(paths)
        @paths = paths
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
          map { |path| build_entry_combinations(path) }.
          flatten
      end

      def filtered_paths
        @_filtered_paths ||=
          paths.
          reject { |path| filter_path?(path) }.
          select { |path| FileUtils.readable_by_all?(path) }.
          map { |path| add_trailing_slash(path) }
      end

      def filter_path?(path)
        dir = File.dirname(path)

        in_diff = in_diff?(path) || in_diff?(dir)
        is_nested = nested?(path) || nested?(dir)
        is_ignored = IncludePathsBuilder::IGNORE_PATHS.include?(path)

        in_diff || is_nested || is_ignored
      end

      def in_diff?(path)
        diff.include?(path)
      end

      def nested?(path)
        File.dirname(path) != "."
      end

      def add_trailing_slash(path)
        if File.directory?(path)
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
        @_all_files ||= Dir.glob("**/*", File::FNM_DOTMATCH).reject do |path|
          path == "." || path.end_with?("/.")
        end
      end
    end
  end
end
