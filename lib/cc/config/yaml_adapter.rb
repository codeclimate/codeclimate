module CC
  class Config
    class YAMLAdapter
      DEFAULT_PATH = ".codeclimate.yml".freeze

      attr_reader :config

      def self.load(path = DEFAULT_PATH)
        new(::YAML.safe_load(File.read(path)))
      end

      def initialize(yaml = {})
        @config = yaml || {}

        upconvert_legacy_yaml!
      end

      private

      def coerce_engine(data)
        if [true, false].include?(data)
          { "enabled" => data }
        elsif data.is_a?(Hash)
          data
        else
          {}
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
        if config.is_a?(Hash) && config.keys.one? && config.key?("file")
          config["file"]
        else
          config
        end
      end

      def upconvert_legacy_yaml!
        config.delete("ratings")

        if config.key?("engines")
          config["plugins"] ||= config.delete("engines")
        end

        plugins = config.fetch("plugins", {})
        plugins.each do |engine, data|
          plugins[engine] = coerce_engine(data)
          if plugins.fetch(engine)["exclude_paths"]
            plugins.fetch(engine)["exclude_patterns"] ||= Array(plugins.fetch(engine).delete("exclude_paths"))
          end
          if plugins.fetch(engine)["config"]
            plugins.fetch(engine)["config"] = convert_to_legacy_file_config(
              plugins.fetch(engine).fetch("config"),
            )
          end
        end

        if config.key?("exclude_paths")
          config["exclude_patterns"] ||= Array(config.delete("exclude_paths"))
        end
      end
    end
  end
end
