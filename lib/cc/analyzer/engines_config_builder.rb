require "securerandom"

module CC
  module Analyzer
    class EnginesConfigBuilder
      Result = Struct.new(
        :name,
        :registry_entry,
        :code_path,
        :config,
        :container_label,
      )

      def initialize(registry:, config:, container_label:, source_dir:, requested_paths:)
        @registry = registry
        @config = config
        @container_label = container_label
        @requested_paths = requested_paths
        @source_dir = source_dir
      end

      def run
        names_and_raw_engine_configs.map do |name, raw_engine_config|
          label = @container_label || SecureRandom.uuid
          engine_config = engine_config(raw_engine_config)
          Result.new(name, @registry[name], @source_dir, engine_config, label)
        end
      end

      private

      def engine_config(raw_engine_config)
        engine_workspace = engine_workspace(raw_engine_config)
        config = raw_engine_config.merge(
          include_paths: engine_workspace.paths,
        )

        normalize_config_file(config)

        config
      end

      def engine_workspace(raw_engine_config)
        if raw_engine_config.key?("exclude_paths")
          workspace.dup.filter(raw_engine_config["exclude_paths"])
        else
          workspace
        end
      end

      def names_and_raw_engine_configs
        {}.tap do |ret|
          (@config.engines || {}).each do |name, raw_engine_config|
            if raw_engine_config.enabled? && @registry.key?(name)
              ret[name] = raw_engine_config
            end
          end
        end
      end

      def workspace
        @workspace ||= Workspace.new(paths: Array(@requested_paths)).filter(@config.exclude_paths)
      end

      # The yaml gem turns a config file string into a hash, but engines expect
      # the string. So we (for now) need to turn it into a string in that one
      # scenario.
      def normalize_config_file(config)
        if config.fetch("config", {}).keys.size == 1 && config["config"].key?("file")
          config["config"] = config["config"]["file"]
        end
      end
    end
  end
end
