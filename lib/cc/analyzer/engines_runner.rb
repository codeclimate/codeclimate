require "securerandom"

module CC
  module Analyzer
    class EnginesRunner
      InvalidEngineName = Class.new(StandardError)
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

      def engines
        @engines ||= Engines.new(
          registry: @registry,
          config: @config,
          container_label: @container_label,
          source_dir: @source_dir,
          requested_paths: @requested_paths
        )
      end

      def run_engine(engine, container_listener)
        @formatter.engine_running(engine) do
          engine.run(@formatter, container_listener)
        end
      end
    end
  end
end
