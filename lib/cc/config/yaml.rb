require "safe_yaml/load"

module CC
  module Config
    class YAML
      DEFAULT_PATH = ".codeclimate.yml".freeze

      attr_reader :engines, :exclude_patterns

      delegate \
        :development?,
        :development=,
        :analysis_paths,
        to: :default

      def initialize(path = DEFAULT_PATH)
        @path = path
        @yaml = SafeYAML.load_file(path) || {}
        @default = Default.new

        upconvert_legacy_yaml!
      end

      def engines
        @engines ||= default.engines | Set.new(plugin_engines)
      end

      def exclude_patterns
        @exclude_patterns ||= yaml.fetch(
          "exclude_patterns",
          default.exclude_patterns,
        )
      end

      def prepare
        Prepare.from_yaml(yaml["prepare"])
      end

      private

      attr_reader :path, :default, :yaml

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
            data["config"] = convert_to_legacy_file_config(data["config"])
          end

          Engine.new(
            name,
            enabled: data.fetch("enabled", true),
            channel: data["channel"],
            config: data
          )
        end
      end

      # Many of our plugins still expect:
      #
      #   { config: PATH }
      #
      # But we document, and hope to eventually move to:
      #
      #   { config: { file: PATH } }
      #
      # We need to munge from the latter to the former when/if we encounter it
      def convert_to_legacy_file_config(config)
        if config.keys.size == 1 && config.key?("file")
          config["file"]
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
