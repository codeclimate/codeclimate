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

      def included_files
        tracked_in_git = `git ls-files -z`.split("\0")
        untracked_in_git = `git ls-files -zo`.split("\0")
        ignored = Tempfile.open(".cc_gitignore") do |tmp|
          tmp.write(File.read(".gitignore")) if File.exist?(".gitignore")
          tmp << @cc_excludes.join("\n")
          tmp.close
          tracked_and_ignored = `git ls-files -zi -X #{tmp.path}`.split("\0")
          untracked_and_ignored = `git ls-files -zio -X #{tmp.path}`.split("\0")
          tracked_and_ignored + untracked_and_ignored
        end
        tracked_in_git + untracked_in_git - ignored
      end

      class Directory
        def initialize(path, included_files)
          @path = path
          @included_files = ensure_hashified(included_files)
          begin
            all_entries = Dir.entries(@path)
            @file_entries, @subdirectories = partition_and_build_from_entries(
              all_entries
            )
            @readable = true
          rescue Errno::EACCES, Errno::EPERM
            @file_entries = []
            @subdirectories = []
            @readable = false
          end
        end

        def all_included?
          @readable && files_all_included? && subdirectories_all_included?
        end

        def included_paths
          if all_included?
            [@path + "/"]
          else
            result = []
            @file_entries.each do |file_entry|
              result << file_entry if @included_files[file_entry]
            end
            @subdirectories.each do |subdirectory|
              result = result.concat(subdirectory.included_paths)
            end
            result
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
          @file_entries.all? { |e| @included_files[e] }
        end

        def partition_and_build_from_entries(all_entries)
          relevant_child_entries = all_entries.reject do |e| 
            %w[. .. .git].include?(e)
          end.map do |e|
            @path == "." ? e : File.join(@path, e)
          end
          subdirectory_entries, file_entries = relevant_child_entries.partition do |e|
            File.directory?(e)
          end
          subdirectories = subdirectory_entries.map do |e|
            Directory.new(e, @included_files)
          end
          [file_entries, subdirectories]
        end

        def subdirectories_all_included?
          @subdirectories.all?(&:all_included?)
        end
      end
    end
  end
end
