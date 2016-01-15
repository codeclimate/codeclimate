module CC
  class Workspace
    class Exclusions
      attr_reader :exclude_paths

      def initialize(exclude_paths)
        @exclude_paths = exclude_paths.map { |p| normalize(p) }.compact
      end

      def include?(path)
        exclude_paths.include?(path)
      end

      def apply?(path)
        exclude_paths.any? do |exclude_path|
          exclude_path.start_with?(path)
        end
      end

      private

      def normalize(pattern)
        normalized = pattern.to_s.sub(%r{/\*\*(/\*)?$}, "")

        if normalized.include?("*")
          $stderr.puts(invalid_exclude_path_warning(pattern))
        else
          normalized
        end
      end

      def invalid_exclude_path_warning(pattern)
        <<-EOM
WARNING: invalid exclude path: #{pattern.inspect}.

Unfortunately, we no longer support wildcard patterns in exclude_paths, only
file paths or directories relative to the project root. This pattern will be
ignored.

If you feel particularly limited by this, please open an Issue at
https://github.com/codeclimate/codeclimate and we'll try to find a
non-exclude_paths-based solution.
        EOM
      end
    end
  end
end
