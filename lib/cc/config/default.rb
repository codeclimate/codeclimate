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
        @development = false
        @engines = Set.new([structure_engine, duplication_engine])
        @exclude_patterns = EXCLUDE_PATTERNS
      end

      def prepare
        Prepare::NoPrepareNeeded.new
      end

      def analysis_paths
        @analysis_paths ||= []
      end

      def development?
        @development
      end

      private

      def structure_engine
        Engine.new(
          "complexity-ruby",
          enabled: true,
          channel: "beta",
          config: {
            "config" => {
              "checks" => json.checks,
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
              "languages" => %w[ruby],
              "checks" => json.checks,
            },
          },
        )
      end

      def json
        @json ||= JSON.new
      end
    end
  end
end
