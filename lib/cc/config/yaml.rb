require "safe_yaml/load"

module CC
  class Config
    class YAML < Config
      DEFAULT_PATH = ".codeclimate.yml".freeze

      def initialize(path = DEFAULT_PATH)
        @path = path
        @yaml = SafeYAML.load_file(path) || {}

        upconvert_legacy_yaml!

        super(
          engines: Set.new(plugin_engines),
          exclude_patterns: yaml.fetch("exclude_patterns", []),
          prepare: Prepare.from_yaml(yaml["prepare"]),
        )
      end

      private

      attr_reader :path, :yaml

      def plugin_engines
        yaml.fetch("plugins", []).map do |name, data|
          plugin_engine(name, data)
        end
      end

      def plugin_engine(name, data)
        if [true, false].include?(data)
          Engine.new(name, enabled: data)
        else
          if data.key?("config")
            data["config"] = upconvert_legacy_file_config(data["config"])
          end

          Engine.new(
            name,
            enabled: data.fetch("enabled", true),
            channel: data["channel"],
            config: data
          )
        end
      end

      # We used to support
      #
      #   { config: PATH }
      #
      # But we document, and have moved to:
      #
      #   { config: { file: PATH } }
      #
      # We need to munge from the former to the latter when we encounter it
      def upconvert_legacy_file_config(config)
        if config.is_a?(String)
          { "file" => config }
        else
          config
        end
      end

      def upconvert_legacy_yaml!
        unless yaml.fetch("version", 0) >= 2
          yaml.delete("ratings")

          if yaml.key?("engines")
            yaml["plugins"] = yaml.delete("engines")
          end

          if yaml.key?("exclude_paths")
            yaml["exclude_patterns"] = yaml.delete("exclude_paths")
          end
        end
      end
    end
  end
end
