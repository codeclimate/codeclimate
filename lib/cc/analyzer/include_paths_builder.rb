module CC
  module Analyzer
    class IncludePathsBuilder
      def initialize(cc_excludes)
        @cc_excludes = cc_excludes
      end

      def build
        root = Directory.new('.', ignored_files)
        paths = root.included_paths
        paths.each do |path|
          raise_on_unreadable_files(path)
        end
        paths
      end

      protected

      def ignored_files
        Tempfile.open(".cc_gitignore") do |tmp|
          tmp.write(File.read(".gitignore")) if File.exist?(".gitignore")
          tmp << @cc_excludes.join("\n")
          tmp.close
          tracked_and_ignored = `git ls-files -zi -X #{tmp.path}`.split("\0")
          untracked_and_ignored = `git ls-files -zio -X #{tmp.path}`.split("\0")
          tracked_and_ignored + untracked_and_ignored
        end
      end

      def included_files
        includable_files - ignored_files
      end

      def includable_files
        tracked_in_git = `git ls-files -z`.split("\0")
        untracked_in_git = `git ls-files -zo`.split("\0")
        tracked_in_git + untracked_in_git
      end

      def raise_on_unreadable_files(path)
        if File.directory?(path)
          raise_on_unreadable_files_in_directory(path)
        elsif !FileUtils.readable_by_all?(path)
          raise CC::Analyzer::UnreadableFileError.new("Can't read #{path}")
        end
      end

      def raise_on_unreadable_files_in_directory(path)
        raw_entries = Dir.entries(path).reject do |e|
          %w(. .. .git).include?(e)
        end
        raw_entries.each do |entry|
          sub_path = File.join(path, entry)
          raise_on_unreadable_files(sub_path)
        end
      end

      class Directory
        def initialize(path, excluded_files)
          @path = path
          @excluded_files = ensure_hashified(excluded_files)
        end

        def all_included?
          readable_by_all? &&
            files_all_included? &&
            subdirectories_all_included?
        end

        def included_paths
          if all_included?
            [@path + "/"]
          elsif readable_by_all?
            result = []
            result = result.concat(included_file_entries)
            result = result.concat(included_subdirectory_results)
            result
          else
            []
          end
        end

        protected

        def ensure_hashified(obj)
          if obj.is_a?(Array)
            result = {}
            obj.each do |included|
              result[included] = true
            end
            result
          else
            obj
          end
        end

        def files_all_included?
          !file_entries.any? { |e| @excluded_files[e] }
        end

        def file_entries
          unless @_file_entries
            @_file_entries = relevant_full_entries.reject do |e|
              File.directory?(e)
            end
          end
          @_file_entries
        end

        def included_file_entries
          file_entries.reject { |file_entry| @excluded_files[file_entry] }
        end

        def included_subdirectory_results
          result = []
          subdirectories.each do |subdirectory|
            result = result.concat(subdirectory.included_paths)
          end
          result
        end

        def readable_by_all?
          FileUtils.readable_by_all?(@path)
        end

        def relevant_full_entries
          unless @_relevant_full_entries
            raw_entries = Dir.entries(@path).reject do |e|
              %w(. .. .git).include?(e)
            end
            @_relevant_full_entries = raw_entries.map do |e|
              @path == "." ? e : File.join(@path, e)
            end
          end
          @_relevant_full_entries
        end

        def subdirectories
          unless @_subdirectories
            entries = relevant_full_entries.select do |e|
              File.directory?(e)
            end
            @_subdirectories = entries.map do |e|
              Directory.new(e, @excluded_files)
            end
          end
          @_subdirectories
        end

        def subdirectories_all_included?
          subdirectories.all?(&:all_included?)
        end
      end
    end
  end
end
