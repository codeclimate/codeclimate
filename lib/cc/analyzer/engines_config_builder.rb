require "securerandom"

module CC
  module Analyzer
    class EnginesConfigBuilder
      class RegistryAdapter < SimpleDelegator
        # Calling this is guarded by Registry#key?(name) so we can assume
        # metadata itself will be present. We own the YAML loaded into the
        # registry, so we can also assume the "channels" key will be present. We
        # can't assume it will have a key for the given channel, but the nil
        # value for the returned image key will trigger the desired error
        # handling.
        def fetch(name, channel)
          metadata = self[name]
          metadata.merge("image" => metadata["channels"][channel.to_s])
        end
      end

      Result = Struct.new(
        :name,
        :registry_entry,
        :code_path,
        :config,
        :container_label,
      )

      def initialize(registry:, config:, container_label:, source_dir:, requested_paths:)
        @registry = RegistryAdapter.new(registry)
        @config = config
        @container_label = container_label
        @requested_paths = requested_paths
        @source_dir = source_dir
      end

      def run
        names_and_raw_engine_configs.map do |name, raw_engine_config|
          label = @container_label || SecureRandom.uuid
          engine_config = engine_config(raw_engine_config)
          engine_metadata = @registry.fetch(name, raw_engine_config.channel)
          Result.new(name, engine_metadata, @source_dir, engine_config, label)
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
        if raw_engine_config.key?("exclude_paths") && !@requested_paths.present?
          base_workspace.clone.tap do |workspace|
            workspace.remove(raw_engine_config["exclude_paths"])
          end
        else
          base_workspace
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

      def base_workspace
        @base_workspace ||= Workspace.new.tap do |workspace|
          workspace.add(@requested_paths)
          unless @requested_paths.present?
            workspace.remove([".git"])
            workspace.remove(@config.exclude_paths)
          end
        end
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
