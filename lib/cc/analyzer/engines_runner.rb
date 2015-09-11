require "securerandom"

module CC
  module Analyzer
    class EnginesRunner
      InvalidEngineName = Class.new(StandardError)
      NoEnabledEngines = Class.new(StandardError)

      def initialize(registry, formatter, source_dir, config, container_label = nil)
        @registry = registry
        @formatter = formatter
        @source_dir = source_dir
        @config = config
        @container_label = container_label
      end

      def run(container_listener = ContainerListener.new)
        raise NoEnabledEngines if engines.empty?

        @formatter.started

        engines.each { |engine| run_engine(engine, container_listener) }

        @formatter.finished
      ensure
        @formatter.close
      end

      private

      def run_engine(engine, container_listener)
        @formatter.engine_running(engine) do
          engine.run(@formatter, container_listener)
        end
      end

      def engines
        @engines ||= enabled_engines.map do |name, config|
          label = @container_label || SecureRandom.uuid

          Engine.new(name, metadata(name), @source_dir, engine_config(config), label)
        end
      end

      def engine_config(config)
        config = config.merge(
          exclude_paths: exclude_paths,
          include_paths: include_paths
        )

        # The yaml gem turns a config file string into a hash, but engines expect the string
        # So we (for now) need to turn it into a string in that one scenario.
        # TODO: update the engines to expect the hash and then remove this.
        if config.fetch("config", {}).keys.size == 1 && config["config"].key?("file")
          config["config"] = config["config"]["file"]
        end

        config
      end

      def enabled_engines
        {}.tap do |ret|
          @config.engines.each do |name, config|
            if config.enabled? && @registry.key?(name)
              ret[name] = config
            end
          end
        end
      end

      def metadata(engine_name)
        @registry[engine_name]
      end

      def exclude_paths
        PathPatterns.new(@config.exclude_paths || []).expanded + gitignore_paths
      end

      def include_paths
        IncludePathsBuilder.new(@config.exclude_paths || []).build
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
