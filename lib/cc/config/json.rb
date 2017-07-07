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
          channel: channel_overrides.fetch("structure", "stable"),
          config: {
            "config" => {
              "checks" => json.fetch("checks", {}),
            },
          },
        )
      end

      def duplication_engine
        base_engine = Engine.new(
          "duplication",
          enabled: true,
          channel: channel_overrides.fetch("duplication", "cronopio"),
          config: {
            "config" => {
              "languages" => %w[javascript ruby],
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
