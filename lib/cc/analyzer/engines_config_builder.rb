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

      def build_engine(engine_class, name, raw_engine_config)
        label = @container_label || SecureRandom.uuid
        engine_config = engine_config(raw_engine_config)
        engine_class.new(
          name, @registry[name], @source_dir, engine_config, label
        )
      end

      def engine_config(raw_engine_config)
        config = raw_engine_config.merge(
          exclude_paths: exclude_paths,
          include_paths: include_paths,
        )
        # The yaml gem turns a config file string into a hash, but engines
        # expect the string. So we (for now) need to turn it into a string in
        # that one scenario.
        # TODO: update the engines to expect the hash and then remove this.
        if config.fetch("config", {}).keys.size == 1 && config["config"].key?("file")
          config["config"] = config["config"]["file"]
        end
        config
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

      def include_paths
        IncludePathsBuilder.new(
          @config.exclude_paths || [], @requested_paths
        ).build
      end

      def exclude_paths
        PathPatterns.new(@config.exclude_paths || []).expanded +
          gitignore_paths
      end

      def gitignore_paths
        if File.exist?(".gitignore")
          `git ls-files --others -i -z --exclude-from .gitignore`.split("\0")
        else
          []
        end
      end
    end
  end
end
