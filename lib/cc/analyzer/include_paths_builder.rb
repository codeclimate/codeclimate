module CC
  module Analyzer
    class IncludePathsBuilder
      def initialize(cc_excludes)
        @cc_excludes = cc_excludes
      end

      def build
        root = Directory.new('.', included_files)
        root.included_paths
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

      class Directory
        def initialize(path, included_files)
          @path = path
          @included_files = ensure_hashified(included_files)
        end

        def all_included?
          readable? && files_all_included? && subdirectories_all_included?
        end

        def included_paths
          if all_included?
            [@path + "/"]
          elsif readable?
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
          file_entries.all? { |e| @included_files[e] }
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
          file_entries.select { |file_entry| @included_files[file_entry] }
        end

        def included_subdirectory_results
          result = []
          subdirectories.each do |subdirectory|
            result = result.concat(subdirectory.included_paths)
          end
          result
        end

        def readable?
          if @_readable.nil?
            begin
              Dir.entries(@path)
              @_readable = true
            rescue Errno::EACCES, Errno::EPERM
              @_readable = false
            end
          end
          @_readable
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
              Directory.new(e, @included_files)
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
