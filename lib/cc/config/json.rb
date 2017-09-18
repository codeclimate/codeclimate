module CC
  class Config
    class JSON < Config
      DEFAULT_PATH = ".codeclimate.json".freeze

      def self.load(path = DEFAULT_PATH)
        new(::JSON.parse(File.open(path).read))
      end

      def initialize(json = {})
        @json = json

        super(
          engines: Set.new([duplication_engine, structure_engine] + plugin_engines),
          exclude_patterns: json.fetch("exclude_patterns", Default::EXCLUDE_PATTERNS),
          prepare: Prepare.from_yaml(json["prepare"]),
        )
      end

      private

      attr_reader \
        :json

      def structure_engine
        Engine.new(
          "structure",
          enabled: true,
          channel: channel_overrides.fetch("structure", "stable"),
          config: {
            "config" => {
              "checks" => json.fetch("checks", {}),
            },
          },
        )
      end

      def duplication_engine
        Engine.new(
          "duplication",
          enabled: true,
          channel: channel_overrides.fetch("duplication", "cronopio"),
          config: {
            "config" => {
              "languages" => Default::DUPLICATION_LANGUAGES,
              "checks" => json.fetch("checks", {}),
            },
          },
        )
      end

      def plugin_engines
        json.fetch("plugins", {}).map do |name, data|
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

      def channel_overrides
        json.fetch("channels", {})
      end
    end
  end
end
