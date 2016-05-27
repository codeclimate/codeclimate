module CC
  module Analyzer
    class EngineRegistry
      def initialize(dev_mode = false)
        @path = File.expand_path("../../../../config/engines.yml", __FILE__)
        @config = YAML.safe_load(File.read(@path))
        @dev_mode = dev_mode
      end

      def [](engine_name)
        if dev_mode?
          { "channels" => { "stable" => "codeclimate/codeclimate-#{engine_name}:latest" } }
        else
          @config[engine_name]
        end
      end

      def list
        @config
      end

      def key?(engine_name)
        return true if dev_mode?
        list.key?(engine_name)
      end

      alias_method :exists?, :key?

      private

      def dev_mode?
        @dev_mode
      end
    end
  end
end
