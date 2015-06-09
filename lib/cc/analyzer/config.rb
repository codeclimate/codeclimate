require "yaml"

module CC
  module Analyzer
    class Config

      BUFFER = "  ".freeze

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

      def engine_enabled?(engine_name)
        engine = @config["engines"][engine_name]
        engine && engine["enabled"]
      end

      def enable_engine(engine_name)
        @config["engines"][engine_name] = { "enabled" => true }
      end

      def attribute_to_s(attribute, buffer="")
        string = ""
        if !attribute.instance_of?(Hash)
          string += " #{attribute}\n"
        else
          attribute.each do |key, value|
            string += "\n#{buffer} #{key}:"
            string += attribute_to_s(value, buffer + BUFFER)
          end
        end
        string
      end

      def to_yaml
        yaml = ""
        @config.each do |key, value|
          if key == "engines"
            yaml += engines_to_yaml
          else
            yaml += "#{key}:"
            yaml += attribute_to_s(value)
          end
        end
        yaml
      end

      def engines_to_yaml
        yaml = "engines:\n"
        @config["engines"].each do |name, engine_config|
          yaml += BUFFER + "#{name}:\n"
          engine_config.each do |key, value|
            if key == "config_file"
              value = value["path"]
            end
            yaml += BUFFER*2 + "#{key}: #{value}\n"
          end
        end
        yaml
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
    end
  end
end
