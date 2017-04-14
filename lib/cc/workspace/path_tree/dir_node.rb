module CC
  class Workspace
    class PathTree
      class DirNode
        def initialize(root_path, children = {})
          @root_path = root_path.dup.freeze
          @children = children.each_with_object({}) do |(k, v), memo|
            memo[k.clone] = v.clone
          end
        end

        def clone
          self.class.new(root_path, children)
        end

        def all_paths
          if populated?
            children.values.flat_map(&:all_paths)
          else
            [File.join(root_path, File::SEPARATOR)]
          end
        end

        def populated?
          children.present?
        end

        def remove(head = nil, *tail)
          return if head.nil? && tail.empty?
          populate_direct_children

          if (child = children[head])
            child.remove(*tail)
            children.delete(head) if !child.populated? || tail.empty?
          end
        end

        def add(head = nil, *tail)
          return if head.nil? && tail.empty?

          if (entry = find_direct_child(head))
            children[entry.basename.to_s.dup.freeze] ||= PathTree.node_for_pathname(entry)
            children[entry.basename.to_s.dup.freeze].add(*tail)
          else
            Analyzer.logger.debug("Couldn't include because part of path doesn't exist: #{File.join(root_path, head)}")
          end
        end

        private

        attr_reader :children, :root_path

        def populate_direct_children
          return if populated?

          Pathname.new(root_path).each_child do |child_path|
            children[child_path.basename.to_s] = PathTree.node_for_pathname(child_path)
          end
        end

        def find_direct_child(name)
          Pathname.new(root_path).children.detect { |c| c.basename.to_s == name }
        end
      end
    end
  end
end
