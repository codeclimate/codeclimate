module CC
  module Analyzer
    # The shared interface, invoked by Builder or CLI::Analyze
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
          formatter.engine_running(engine) do
            run_engine(engine)
          end
        end

        formatter.finished
      ensure
        formatter.close
      end

      private

      attr_reader :config, :formatter, :listener, :registry

      def run_engine(engine)
        engine_details = registry.fetch_engine_details(
          engine, development: config.development?,
        )

        runnable_engine = Engine.new(
          engine.name,
          {
            "image" => engine_details.image,
            "command" => engine_details.command,
          },
          engine.to_config_json.merge(
            include_paths: workspace.paths,
          ),
          engine.container_label,
        )

        runnable_engine.run(formatter, listener)
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
