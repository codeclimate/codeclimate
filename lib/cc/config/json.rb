module CC
  class Config
    class JSON < Config
      DEFAULT_PATH = ".codeclimate.json".freeze

      def initialize(path = DEFAULT_PATH)
        @path = path
        @json = ::JSON.parse(File.open(path).read) || {}

        super(
          engines: Set.new([duplication_engine, structure_engine] + plugin_engines),
          exclude_patterns: json.fetch("exclude_patterns", Default::EXCLUDE_PATTERNS)
        )
      end

      private

      attr_reader \
        :path,
        :json

      def structure_engine
        override = all_configured_engines.detect { |engine| engine.name == "structure" }

        if override
          set_engine_checks(override, json.fetch("checks", {}))
          override
        else
          Engine.new(
            "structure",
            enabled: true,
            config: {
              "config" => {
                "checks" => json.fetch("checks", {}),
              },
            },
          )
        end
      end

      def duplication_engine
        override = all_configured_engines.detect { |engine| engine.name == "duplication" }

        if override
          set_engine_checks(override, json.fetch("checks", {}))
          override
        else
          Engine.new(
            "duplication",
            enabled: true,
            channel: "cronopio",
            config: {
              "config" => {
                "languages" => %w[javascript ruby],
                "checks" => json.fetch("checks", {}),
              },
            },
          )
        end
      end

      def plugin_engines
        all_configured_engines.reject do |engine|
          %w[structure duplication].include?(engine.name)
        end
      end

      def all_configured_engines
        @all_configured_engines ||= json.fetch("plugins", {}).map do |name, data|
          plugin_engine(name, data)
        end
      end

      def plugin_engine(name, data)
        Engine.new(
          name,
          enabled: data.fetch("enabled", true),
          channel: data["channel"],
          config: data
        )
      end

      def set_engine_checks(engine, checks)
        engine.config["config"] ||= {}
        engine.config["config"]["checks"] ||= checks
      end
    end
  end
end
