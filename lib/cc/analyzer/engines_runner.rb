require "securerandom"

module CC
  module Analyzer
    class EnginesRunner
      NoEnabledEngines = Class.new(StandardError)

      def initialize(registry, formatter, source_dir, config, requested_paths = [], container_label = nil)
        @registry = registry
        @formatter = formatter
        @source_dir = source_dir
        @config = config
        @requested_paths = requested_paths
        @container_label = container_label
      end

      def run(container_listener = ContainerListener.new)
        raise NoEnabledEngines if engines.empty?

        @formatter.started

        engines.each { |engine| run_engine(engine, container_listener) }

        @formatter.finished
      ensure
        @formatter.close if @formatter.respond_to?(:close)
      end

      private

      attr_reader :requested_paths

      def build_engine(built_config)
        Engine.new(
          built_config.name,
          built_config.registry_entry,
          built_config.code_path,
          built_config.config,
          built_config.container_label,
        )
      end

      def configs
        EnginesConfigBuilder.new(
          registry: @registry,
          config: @config,
          container_label: @container_label,
          source_dir: @source_dir,
          requested_paths: requested_paths,
        ).run
      end

      def engines
        @engines ||= configs.map { |result| build_engine(result) }
      end

      def run_engine(engine, container_listener)
        @formatter.engine_running(engine) do
          engine.run(@formatter, container_listener)
        end
      end
    end
  end
end
