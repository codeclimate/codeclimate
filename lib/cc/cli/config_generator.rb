require "shellwords"

module CC
  module CLI
    class ConfigGenerator
      CODECLIMATE_YAML = Command::CODECLIMATE_YAML
      AUTO_EXCLUDE_PATHS = %w(config/ db/ dist/ features/ node_modules/ script/ spec/ test/ tests/ vendor/).freeze

      EmptyWorkspaceError = Class.new(StandardError)

      def self.for(filesystem, engine_registry, upgrade_requested)
        if upgrade_requested && upgrade_needed?(filesystem)
          UpgradeConfigGenerator.new(filesystem, engine_registry)
        else
          ConfigGenerator.new(filesystem, engine_registry)
        end
      end

      def initialize(filesystem, engine_registry)
        @filesystem = filesystem
        @engine_registry = engine_registry
      end

      def can_generate?
        true
      end

      def eligible_engines
        return @eligible_engines if @eligible_engines

        engines = engine_registry.list
        @eligible_engines = engines.each_with_object({}) do |(name, config), result|
          if engine_eligible?(config)
            result[name] = config
          end
        end
      end

      def errors
        []
      end

      def exclude_paths
        @exclude_paths ||= AUTO_EXCLUDE_PATHS.select { |path| filesystem.exist?(path) }
      end

      def post_generation_verb
        "generated"
      end

      private

      attr_reader :engine_registry, :filesystem

      def self.upgrade_needed?(filesystem)
        if filesystem.exist?(CODECLIMATE_YAML)
          YAML.safe_load(File.read(CODECLIMATE_YAML))["languages"].present?
        end
      end

      def engine_eligible?(engine)
        !engine["community"] && engine["enable_regexps"].present? && files_exist?(engine)
      end

      def files_exist?(engine)
        workspace_files.any? do |path|
          engine["enable_regexps"].any? { |re| Regexp.new(re).match(path) }
        end
      end

      def non_excluded_paths
        @non_excluded_paths ||= begin
          excludes = exclude_paths.map { |path| path.chomp("/") }
          filesystem.ls.reject do |path|
            path.starts_with?(".") || excludes.include?(path)
          end
        end
      end

      def workspace_files
        @workspace_files ||= Dir.chdir(filesystem.root) do
          if non_excluded_paths.empty?
            raise EmptyWorkspaceError, "Your workspace is empty: there are no files for us to check!"
          else
            find_cmd = "find #{non_excluded_paths.map(&:shellescape).join(' ')} -type f -print0"
            `#{find_cmd}`.strip.split("\0").map do |path|
              path.sub(%r{^\.\/}, "")
            end
          end
        end
      end
    end
  end
end
