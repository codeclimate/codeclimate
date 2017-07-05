module CC
  class Config
    class JSON < Config
      DEFAULT_PATH = ".codeclimate.json".freeze

      def initialize(path = DEFAULT_PATH)
        @path = path
        @json = ::JSON.parse(File.open(path).read) || {}

        super(
          engines: Set.new([duplication_engine, structure_engine]),
          exclude_patterns: json.fetch("exclude_patterns", Default::EXCLUDE_PATTERNS)
        )
      end

      private

      attr_reader \
        :path,
        :json

      def structure_engine
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

      def duplication_engine
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
  end
end
