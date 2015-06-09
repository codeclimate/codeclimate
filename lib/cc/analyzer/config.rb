require "yaml"

module CC
  module Analyzer
    class Config

      def initialize(config_body)
        @config = YAML.safe_load(config_body) || {"engines"=> {} }
        @config["engines"] ||= {}

        expand_shorthand
        expand_references
      end

      def to_hash
        @config
      end

      def engine_names
        @config["engines"].keys
      end

      def engine_present?(engine_name)
        @config["engines"][engine_name].present?
      end

      def engine_enabled?(engine_name)
        @config["engines"][engine_name] && @config["engines"][engine_name]["enabled"]
      end

      def enable_engine(engine_name)
        if engine_present?(engine_name)
          @config["engines"][engine_name]["enabled"] = true
        else
          @config["engines"][engine_name] = { "enabled" => true }
        end
      end

      def to_yaml
        contract_references
        @config.to_yaml
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
              engine_config["config_file"] = { "path" => "#{path}", "content" => File.read(path) }
            end
          end
        end
      end

      def contract_references
        @config["engines"].each do |name, engine_config|
          if engine_config["config_file"]
            @config["engines"][name]["config_file"] = engine_config["config_file"]["path"]
          end
        end
      end
    end
  end
end
