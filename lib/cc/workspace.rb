module CC
  class Workspace
    autoload :Exclusion, "cc/workspace/exclusion"
    autoload :PathTree, "cc/workspace/path_tree"

    def initialize(path_tree = PathTree.for_path("."))
      @path_tree = path_tree
    end

    def clone
      self.class.new(path_tree.clone)
    end

    def paths
      path_tree.all_paths
    end

    def add(paths)
      if paths.present?
        path_tree.include_paths(paths)
      end
    end

    def remove(patterns)
      Array(patterns).each do |pattern|
        exclusion = Exclusion.new(pattern)
        if exclusion.negated?
          path_tree.include_paths(exclusion.expand)
        else
          path_tree.exclude_paths(exclusion.expand)
        end
      end
    end

    private

    attr_reader :path_tree
  end
end
