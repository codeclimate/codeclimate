require "pathname"
require "set"

module CC
  class Workspace
    class PathTree
      autoload :DirNode, "cc/workspace/path_tree/dir_node"
      autoload :FileNode, "cc/workspace/path_tree/file_node"

      def self.node_for_pathname(pathname)
        if pathname.directory?
          DirNode.new(pathname.to_s)
        else
          FileNode.new(pathname.to_s)
        end
      end

      def self.for_path(path)
        new(node_for_pathname(Pathname.new(path)))
      end

      def initialize(root_node)
        @root_node = root_node
      end

      def clone
        self.class.new(root_node.clone)
      end

      def exclude_paths(paths)
        paths.each { |path| root_node.remove(*normalized_path_pieces(path)) }
      end

      def include_paths(paths)
        paths.each { |path| root_node.add(*normalized_path_pieces(path)) }
      end

      delegate :all_paths, to: :root_node

      private

      attr_reader :root_node

      def normalized_path_pieces(path)
        Pathname.new(path).cleanpath.to_s.split(File::SEPARATOR).reject(&:blank?)
      end
    end
  end
end
