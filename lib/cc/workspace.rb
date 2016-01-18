module CC
  class Workspace
    autoload :Exclusions, "cc/workspace/exclusions"
    autoload :PathTree, "cc/workspace/path_tree"
    autoload :PathsValidator, "cc/workspace/paths_validator"

    def initialize(paths: nil, prefix: "")
      @prefix = prefix

      if paths.present?
        validator = PathsValidator.new(paths)
        validator.run

        @paths = paths
      end

      CLI.debug("workspace initialize", prefix: prefix)
    end

    def paths
      @paths || ["./"]
    end

    def filter(exclude_paths)
      return self unless exclude_paths.present?

      exclusions = Exclusions.new(exclude_paths)

      CLI.debug("workspace filter start", exclude_paths: exclude_paths)

      @paths ||= Dir.glob("*", File::FNM_DOTMATCH)
      @paths = @paths.flat_map { |name| expand(name, exclusions) }

      CLI.debug("workspace filter end", paths: paths)

      self
    end

    private

    attr_reader :prefix

    def expand(name, exclusions)
      path = "#{prefix}#{name}"

      return [] if %w[. .. .git].include?(name)
      return [] if exclusions.include?(undir(path))
      return [path] unless File.directory?(name)
      return [dir(path)] unless exclusions.apply?(undir(path))

      CLI.debug("workspace filter recurse", prefix: prefix, path: name)

      Dir.chdir(name) do
        workspace = self.class.new(prefix: dir(path))
        workspace.filter(exclusions.exclude_paths).paths
      end
    end

    def dir(path)
      "#{undir(path)}#{File::SEPARATOR}"
    end

    def undir(path)
      path.sub(/#{File::SEPARATOR}$/, "")
    end
  end
end
