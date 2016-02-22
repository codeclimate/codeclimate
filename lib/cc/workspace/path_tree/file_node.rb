module CC
  class Workspace
    class PathTree
      class FileNode
        def initialize(root_path)
          @root_path = root_path.dup.freeze
        end

        def all_paths
          [root_path]
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

        private

        attr_reader :root_path
      end
    end
  end
end
