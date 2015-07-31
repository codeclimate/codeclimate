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

      def run
        raise NoEnabledEngines if engines.empty?

        Analyzer.logger.info("running #{engines.size} engines")

        @formatter.started

        engines.each { |engine| run_engine(engine) }

        @formatter.finished
      ensure
        @formatter.close
      end

      private

      def run_engine(engine)
        Analyzer.logger.info("starting engine #{engine.name}")

        Analyzer.statsd.time("engines.time") do
          Analyzer.statsd.time("engines.names.#{engine.name}.time") do
            @formatter.engine_running(engine) do
              engine.run(@formatter)
            end
          end
        end

        Analyzer.logger.info("finished engine #{engine.name}")
      end

      def engines
        @engines ||= enabled_engines.map do |name, config|
          metadata = registry_lookup(name)
          label = @container_label || SecureRandom.uuid

          Engine.new(name, metadata, @source_dir, engine_config(config), label)
        end
      end

      def engine_config(config)
        config = config.merge(exclude_paths: exclude_paths)

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
            if config.enabled?
              ret[name] = config
            end
          end
        end
      end

      def registry_lookup(engine_name)
        if (metadata = @registry[engine_name])
          metadata
        else
          raise InvalidEngineName, "unknown engine name: #{engine_name}"
        end
      end

      def exclude_paths
        PathPatterns.new(@config.exclude_paths || []).expanded
      end
    end
  end
end
