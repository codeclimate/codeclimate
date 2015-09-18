require "file_utils_ext"

module CC
  module Analyzer
    class IncludePathsBuilder
      def self.relevant_entries(path)
        Dir.entries(path).reject do |e|
          %w(. .. .git).include?(e) || File.symlink?(File.join(path, e))
        end
      end

      def initialize(cc_exclude_paths)
        @cc_exclude_paths = cc_exclude_paths
      end

      def build
        root = Directory.new('.', ignored_files)
        paths = root.included_paths
        paths.each do |path|
          raise_on_unreadable_files(path)
        end
      end

      protected

      def ignored_files
        Tempfile.open(".cc_gitignore") do |tmp|
          tmp.write(File.read(".gitignore")) if File.exist?(".gitignore")
          tmp << @cc_exclude_paths.join("\n")
          tmp.close
          tracked_and_ignored = `git ls-files -zi -X #{tmp.path}`.split("\0")
          untracked_and_ignored = `git ls-files -zio -X #{tmp.path}`.split("\0")
          tracked_and_ignored + untracked_and_ignored
        end
      end

      def raise_on_unreadable_files(path)
        if File.directory?(path)
          raise_on_unreadable_files_in_directory(path)
        elsif !FileUtils.readable_by_all?(path)
          raise CC::Analyzer::UnreadableFileError, "Can't read #{path}"
        end
      end

      def raise_on_unreadable_files_in_directory(path)
        IncludePathsBuilder.relevant_entries(path).each do |entry|
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
            result += included_file_entries
            result += included_subdirectory_results
            result
          else
            []
          end
        end

        protected

        def ensure_hashified(obj)
          if obj.is_a?(Array)
            obj.each_with_object({}) do |included, result|
              result[included] = true
            end
          else
            obj
          end
        end

        def files_all_included?
          file_entries.none? { |e| @excluded_files[e] }
        end

        def file_entries
          @file_entries ||= relevant_full_entries.reject do |e|
            File.directory?(e)
          end
        end

        def full_entry(entry)
          if @path == "."
            entry
          else
            File.join(@path, entry)
          end
        end

        def included_file_entries
          file_entries.reject { |file_entry| @excluded_files[file_entry] }
        end

        def included_subdirectory_results
          subdirectories.each_with_object([]) do |subdirectory, result|
            result.concat(subdirectory.included_paths)
          end
        end

        def readable_by_all?
          FileUtils.readable_by_all?(@path)
        end

        def relevant_full_entries
          unless @relevant_full_entries
            raw_entries = IncludePathsBuilder.relevant_entries(@path)
            @relevant_full_entries = raw_entries.map do |e|
              full_entry(e)
            end
          end
          @relevant_full_entries
        end

        def subdirectories
          unless @subdirectories
            entries = relevant_full_entries.select do |e|
              File.directory?(e)
            end
            @subdirectories = entries.map do |e|
              Directory.new(e, @excluded_files)
            end
          end
          @subdirectories
        end

        def subdirectories_all_included?
          subdirectories.all?(&:all_included?)
        end
      end
    end
  end
end
