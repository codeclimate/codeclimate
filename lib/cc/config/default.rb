module CC
  class Config
    class Default < Config
      EXCLUDE_PATTERNS = %w[
        config/
        db/
        dist/
        features/
        node_modules/
        script/
        spec/
        test/
        tests/
        vendor/
      ]

      def initialize
        super(
          engines: Set.new([structure_engine, duplication_engine]),
          exclude_patterns: EXCLUDE_PATTERNS,
        )
      end

      private

      def structure_engine
        Engine.new(
          "structure",
          enabled: true,
          channel: "beta",
        )
      end

      def duplication_engine
        Engine.new(
          "duplication",
          enabled: true,
          channel: "cronopio",
          config: {
            "config" => {
              "languages" => %w[ruby],
            }
          },
        )
      end
    end
  end
end
