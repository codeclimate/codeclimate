require "safe_yaml"

module CC
  module Analyzer
    class EngineRegistry
      def initialize(path = "config/engines.yml")
        @path = path
        @config = YAML.safe_load_file(@path)
      end

      def [](engine_name)
        @config[engine_name]
      end

      def list
        @config
      end
    end
  end
end

