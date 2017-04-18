module CC
  module Config
    class Default
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

      attr_reader :engines, :exclude_patterns
      attr_writer :development

      def initialize
        load_defaults
      end

      def reload
        load_defaults
        self
      end

      def analysis_paths
        @analysis_paths ||= []
      end

      def development?
        @development
      end

      private

      def load_defaults
        @development = false
        @engines = Set.new([structure_engine, duplication_engine])
        @exclude_patterns = EXCLUDE_PATTERNS
      end

      def structure_engine
        Engine.new(
          "complexity-ruby",
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
            languages: %w[ruby],
          },
        )
      end
    end
  end
end
