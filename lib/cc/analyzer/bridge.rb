module CC
  module Analyzer
    # The shared interface, invoked by Builder or CLI::Analyze
    #
    # Input:
    #   - config
    #     - engines
    #     - exclude_patterns
    #     - development?
    #     - analysis_paths
    #   - formatter
    #     - started
    #     - engine_running
    #     - finished
    #     - close
    #   - listener
    #     - started(engine, details)
    #     - finished(engine, details, result)
    #   - registry
    #
    # Only raises if Listener raises
    #
    class Bridge
      def initialize(config:, formatter:, listener:, registry:)
        @config = config
        @formatter = formatter
        @listener = listener
        @registry = registry
      end

      def run
        formatter.started

        config.engines.each do |engine|
          next unless engine.enabled?

          formatter.engine_running(engine) do
            result = nil
            engine_details = nil

            begin
              engine_details = registry.fetch_engine_details(
                engine,
                development: config.development?,
              )
              listener.started(engine, engine_details)
              result = run_engine(engine, engine_details)
            rescue CC::EngineRegistry::EngineDetailsNotFoundError => ex
              result = Container::Result.skipped(ex)
            end

            listener.finished(engine, engine_details, result)
            result
          end
        end

        formatter.finished
      ensure
        formatter.close
      end

      private

      attr_reader :config, :formatter, :listener, :registry

      def run_engine(engine, engine_details)
        # Analyzer::Engine doesn't have the best interface, but we're limiting
        # our refactors for now.
        Engine.new(
          engine.name,
          {
            "image" => engine_details.image,
            "command" => engine_details.command,
            "memory" => engine_details.memory,
          },
          engine.config.merge(
            "channel" => engine.channel,
            "include_paths" => engine_workspace(engine).paths,
          ),
          engine.container_label,
        ).run(formatter)
      end

      def engine_workspace(engine)
        if engine.exclude_patterns.any?
          workspace.clone.tap do |engine_workspace|
            engine_workspace.remove(engine.exclude_patterns)
          end
        else
          workspace
        end
      end

      def workspace
        @workspace ||= Workspace.new.tap do |workspace|
          workspace.add(config.analysis_paths)

          unless config.analysis_paths.any?
            workspace.remove([".git"])
            workspace.remove(config.exclude_patterns)
          end
        end
      end
    end
  end
end
