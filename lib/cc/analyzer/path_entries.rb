module CC
  module Analyzer
    class PathEntries
      def initialize(initial_path)
        @initial_path = initial_path.gsub(%r{/$}, "")
      end

      def entries
        if File.directory?(initial_path)
          all_entries.reject do |path|
            path.end_with?("/.") || path.start_with?(".git/")
          end
        else
          initial_path
        end
      end

      private

      attr_reader :initial_path

      def all_entries
        Dir.glob("#{initial_path}/**/*", File::FNM_DOTMATCH).push(initial_path)
      end
    end
  end
end
