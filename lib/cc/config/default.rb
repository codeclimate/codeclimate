module CC
  class Config
    class Default < Config
      DUPLICATION_LANGUAGES = %w[
        java
        javascript
        php
        python
        ruby
      ].freeze

      # intentionally not sorted
      ENGINE_NAMES = %w[structure duplication]

      EXCLUDE_PATTERNS = %w[
        config/
        db/
        dist/
        features/
        **/node_modules/
        script/
        **/spec/
        **/test/
        **/tests/
        **/vendor/
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
        )
      end

      def duplication_engine
        Engine.new(
          "duplication",
          enabled: true,
          channel: "cronopio",
          config: {
            "config" => {
              "languages" => DUPLICATION_LANGUAGES,
            }
          },
        )
      end
    end
  end
end
