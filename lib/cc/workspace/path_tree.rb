require "pathname"
require "set"

module CC
  class Workspace
    class PathTree
      def self.create(pathname)
        if pathname.directory?
          new(pathname.to_s)
        else
          FileNode.new(pathname.to_s)
        end
      end

      def initialize(root_path, children = {})
        @root_path = root_path.dup.freeze
        @children = children
      end

      def clone
        self.class.new(root_path, children.dup)
      end

      def exclude_paths(paths)
        paths.each { |path| remove(*normalized_path_pieces(path)) }
      end

      def include_paths(paths)
        paths.each { |path| add(*normalized_path_pieces(path)) }
      end

      def all_paths
        if populated?
          children.values.flat_map(&:all_paths)
        else
          [File.join(root_path, File::SEPARATOR)]
        end
      end

      protected

      def populated?
        children.present?
      end

      def remove(head = nil, *tail)
        return if head.nil? && tail.empty?
        populate_direct_children

        if (child = children[head])
          child.remove(*tail)
          children.delete(head) unless child.populated?
        end
      end

      def add(head = nil, *tail)
        return if head.nil? && tail.empty?

        if (entry = find_direct_child(head))
          children[entry.basename.to_s] = self.class.create(entry)
          children[entry.basename.to_s].add(*tail)
        else
          CLI.debug("Couldn't include because part of path doesn't exist.", path: File.join(root_path, head))
        end
      end

      private

      attr_reader :children, :root_path

      def populate_direct_children
        return if populated?

        Pathname.new(root_path).each_child do |child_path|
          children[child_path.basename.to_s] = self.class.create(child_path)
        end
      end

      def find_direct_child(name)
        Pathname.new(root_path).children.detect { |c| c.basename.to_s == name }
      end

      def normalized_path_pieces(path)
        Pathname.new(path).cleanpath.to_s.split(File::SEPARATOR).reject(&:blank?)
      end

      class FileNode
        def initialize(root_path)
          @root_path = root_path.dup.freeze
        end

        def all_paths
          [@root_path]
        end

        def populated?
          false
        end

        def remove(*)
          # this space intentionally left blank
        end

        def add(*)
          # this space intentionally left blank
        end
      end
    end
  end
end
