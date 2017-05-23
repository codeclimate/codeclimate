module CC
  class Config
    class JSON < Config
      DEFAULT_PATH = ".codeclimate.json".freeze

      def initialize(path = DEFAULT_PATH)
        @path = path
        @json = ::JSON.parse(File.open(path).read) || {}

        super(
          engines: Set.new([structure_engine]),
        )
      end

      private

      attr_reader \
        :path,
        :json

      def structure_engine
        Engine.new(
          "complexity-ruby",
          enabled: true,
          channel: "beta",
          config: {
            "enabled": true,
            "config" => {
              "checks" => json.fetch("checks", []),
            },
          },
        )
      end
    end
  end
end
