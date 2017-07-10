module CC
  module Analyzer
    class Plugins
      def initialize
        # For now, always use our registry because it's where auto_enable_paths
        # live. This means we can never auto-enable (e.g.) brakeman-pro.
        @registry = CC::EngineRegistry.new
      end

      def auto_enable_engines(config)
        registry.each_engine do |engine, engine_details|
          engine_details.auto_enable_paths.each do |path|
            if File.exist?(path)
              engine.enabled = true
              config.engines << engine
              break
            end
          end
        end
      end

      private

      attr_reader :registry
    end
  end
end
