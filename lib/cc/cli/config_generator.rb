module CC
  module CLI
    class ConfigGenerator
      CODECLIMATE_YAML = Command::CODECLIMATE_YAML
      AUTO_EXCLUDE_PATHS = %w(config/ db/ features/ node_modules/ script/ spec/ test/ tests/ vendor/).freeze

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
        AUTO_EXCLUDE_PATHS.select { |path| filesystem.exist?(path) }
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
        filesystem.any? do |path|
          engine["enable_regexps"].any? { |re| Regexp.new(re).match(path) }
        end
      end
    end
  end
end
