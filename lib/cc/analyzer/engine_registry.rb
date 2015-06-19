require "safe_yaml"

module CC
  module Analyzer
    class EngineRegistry
      def initialize
        @path = File.expand_path("../../../../config/engines.yml", __FILE__)
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

