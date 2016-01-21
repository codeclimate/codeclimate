module CC
  class Workspace
    autoload :Exclusions, "cc/workspace/exclusions"
    autoload :PathTree, "cc/workspace/path_tree"
    autoload :PathsValidator, "cc/workspace/paths_validator"

    DEFAULT_PATH = "."

    def initialize(paths: nil)
      @path_tree = PathTree.new(DEFAULT_PATH)
      if paths.present?
        validator = PathsValidator.new(paths)
        validator.run

        path_tree.include_paths(paths)
      end

      CLI.debug("workspace initialize")
    end

    def paths
      path_tree.all_paths
    end

    def filter(exclude_paths)
      return self unless exclude_paths.present?

      exclusions = Exclusions.new(exclude_paths)

      CLI.debug("workspace filter start", exclude_paths: exclude_paths)

      exclusions.exclude_paths.each do |exclusion|
        if exclusions.glob?(exclusion)
          path_tree.exclude_paths(exclusions.expanded_glob(exclusion))
        else
          path_tree.exclude_paths([exclusion])
        end
      end

      CLI.debug("workspace filter end", paths: paths)

      self
    end

    private

    attr_reader :path_tree
  end
end
