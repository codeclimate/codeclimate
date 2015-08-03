require "safe_yaml"

module CC
  module Analyzer
    class EngineRegistry
      def initialize(dev_mode = false)
        @path = File.expand_path("../../../../config/engines.yml", __FILE__)
        @config = YAML.safe_load_file(@path)
        @dev_mode = dev_mode
      end

      def [](engine_name)
        if dev_mode?
          { "image" => "codeclimate/codeclimate-#{engine_name}:latest" }
        else
          @config[engine_name]
        end
      end

      def list
        @config
      end

      def has_key?(engine_name)
        return true if dev_mode?
        list.has_key?(engine_name)
      end

      alias exists? has_key?

      private

      def dev_mode?
        @dev_mode
      end
    end
  end
end

