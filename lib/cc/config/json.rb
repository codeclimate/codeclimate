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
        base_engine = Engine.new(
          "structure",
          enabled: true,
          config: {
            "config" => {
              "checks" => json.fetch("checks", {}),
            },
          },
        )
        override = all_configured_engines.detect { |engine| engine.name == "structure" }

        if override
          base_engine.merge(override)
        else
          base_engine
        end
      end

      def duplication_engine
        base_engine = Engine.new(
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
        override = all_configured_engines.detect { |engine| engine.name == "duplication" }

        if override
          base_engine.merge(override)
        else
          base_engine
        end
      end

      def plugin_engines
        all_configured_engines.select(&:plugin?)
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
    end
  end
end
