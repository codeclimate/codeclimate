require "pathname"
require "set"

module CC
  class Workspace
    class PathTree
      def initialize(root_path)
        @root_path = root_path
        @child_dirs = Hash.new
        @child_files = Set.new
      end

      def exclude_paths(paths)
        paths.each { |path| delete(path.split(File::SEPARATOR)) }
      end

      def include_paths(paths)
        paths.each { |path| insert(path.split(File::SEPARATOR)) }
      end

      def all_paths
        collect_paths(include_parent: false).sort.uniq
      end

      protected

      attr_reader :child_dirs, :root_path, :child_files

      def populated?
        !(child_dirs.empty? &&  child_files.empty?)
      end

      def delete(path_pieces)
        populate_all
        if 1 == path_pieces.size
          child_dirs.delete(path_pieces[0])
          child_files.delete(path_pieces[0])
        else
          #TODO: child might not exist
          child_dir = child_dirs[path_pieces[0]]
          child_dir.delete(path_pieces.drop(1))
          child_dirs.delete(path_pieces[0]) if !child_dir.populated?
        end
      end

      def insert(path_pieces)
        return if path_pieces.empty?
        entry = Pathname.new(root_path).children.detect { |c| c.basename.to_s == path_pieces[0] }
        if entry && entry.directory?
          child_dirs[entry.basename.to_s] = PathTree.new(entry.to_s)
          child_dirs[entry.basename.to_s].insert(path_pieces.drop(1))
        elsif entry && entry.file? && path_pieces.count == 1
          child_files << entry.basename.to_s
        else
          CLI.debug("Couldn't exclude because part of path doesn't exist", path: File.join(path_pieces))
        end
      end

      def collect_paths(include_parent: true)
        paths = []
        if populated?
          paths += child_files.map { |child_file| formatted_path(include_parent, child_file) }
          paths += child_dirs.flat_map do |child_dir, child_tree|
            if child_tree.populated?
              child_tree.collect_paths
            else
              File.join(formatted_path(include_parent, child_dir), File::SEPARATOR)
            end
          end
        else
          paths << File.join(root_path, File::SEPARATOR)
        end

        paths
      end

      private

      def populate_all
        return if populated?

        Pathname.new(root_path).each_child do |child_path|
          if child_path.directory?
            child_dirs[child_path.basename.to_s] = self.class.new(child_path.to_s)
          else
            child_files << child_path.basename.to_s
          end
        end
      end

      def formatted_path(include_parent, path)
        if include_parent
          File.join(root_path, path)
        else
          path
        end
      end
    end
  end
end

