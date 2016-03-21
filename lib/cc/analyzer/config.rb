module CC
  module Analyzer
    # TODO: replace each use of this with CC::Yaml and remove it
    class Config
      def initialize(config_body)
        @config = YAML.safe_load(config_body) || { "engines" => {} }
        @config["engines"] ||= {}

        expand_shorthand
      end

      def to_hash
        @config
      end

      def engine_config(engine_name)
        @config["engines"][engine_name] || {}
      end

      def engine_names
        @config["engines"].keys.select { |name| engine_enabled?(name) }
      end

      def engine_present?(engine_name)
        @config["engines"][engine_name].present?
      end

      def engine_enabled?(engine_name)
        @config["engines"][engine_name] && @config["engines"][engine_name]["enabled"]
      end

      def enable_engine(engine_name)
        if engine_present?(engine_name)
          @config["engines"][engine_name]["enabled"] = true
        else
          @config["engines"][engine_name] = { "enabled" => true }
          enable_default_config(engine_name) if default_config(engine_name)
        end
      end

      def enable_default_config(engine_name)
        @config["engines"][engine_name]["config"] = default_config(engine_name)
      end

      def exclude_paths
        @config["exclude_paths"]
      end

      def disable_engine(engine_name)
        if engine_present?(engine_name) && engine_enabled?(engine_name)
          @config["engines"][engine_name]["enabled"] = false
        end
      end

      def remove_engine(engine_name)
        if engine_present?(engine_name)
          @config["engines"].delete(engine_name)
        end
      end

      def to_yaml
        @config.to_yaml
      end

      private

      def expand_shorthand
        @config["engines"].each do |name, engine_config|
          if [true, false].include?(engine_config)
            @config["engines"][name] = { "enabled" => engine_config }
          end
        end
      end

      def default_config(engine_name)
        if (engine_config = engine_registry[engine_name])
          engine_config["default_config"]
        end
      end

      def engine_registry
        @engine_registry ||= CC::Analyzer::EngineRegistry.new
      end
    end
  end
end
