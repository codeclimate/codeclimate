require "yaml"

module CC
  module Analyzer
    class Config

      def self.from_file(path)
        new(File.read(path))
      end

      def initialize(config_body)
        @config = YAML.safe_load(config_body)

        expand_shorthand
        expand_references
      end

      def to_hash
        @config
      end

      def engine_names
        @config["engines"].keys
      end

    private

      def expand_shorthand
        @config["engines"].each do |name, engine_config|
          if [true, false].include?(engine_config)
            @config["engines"][name] = { "enabled" => engine_config }
          end
        end
      end

      def expand_references
        @config["engines"].each do |name, engine_config|
          if (path = engine_config["config_file"])
            if File.exist?(path)
              engine_config["config_file"] = File.read(path)
            end
          end
        end
      end

    end
  end
end
