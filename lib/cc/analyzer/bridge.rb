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
        plugins = Plugins.new
        plugins.auto_enable_engines(config)

        formatter.started

        config.engines.each do |engine|
          next unless engine.enabled?

          formatter.engine_running(engine) do
            result = nil
            engine_details = nil

            begin
              engine_details = registry.fetch_engine_details(
                engine, development: config.development?,
              )
              listener.started(engine, engine_details)
              result = run_engine(engine, engine_details)
            rescue CC::EngineRegistry::EngineDetailsNotFoundError => ex
              result = Container::Result.from_exception(ex)
            end

            listener.finished(engine, engine_details, result)
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
          },
          engine.config.merge(
            "channel" => engine.channel,
            "include_paths" => workspace.paths,
          ),
          engine.container_label,
        ).run(formatter)
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
