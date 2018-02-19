module CC
  class Config
    class DefaultAdapter
      # intentionally not sorted: we want them in a particular order
      ENGINES = {
        "structure".freeze => "stable".freeze,
        "duplication".freeze => "stable".freeze,
      }.freeze

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
        Tests/
        **/vendor/
        **/*_test.go
        **/*.d.ts
      ].freeze

      attr_reader :config

      def initialize(data = {})
        @config = data

        apply_default_excludes
        apply_default_engines
      end

      private

      def apply_default_engines
        config["plugins"] ||= {}

        ENGINES.each do |name, channel|
          config["plugins"][name] ||= {}
          unless [true, false].include?(config["plugins"][name]["enabled"])
            config["plugins"][name]["enabled"] = true
          end
          config["plugins"][name]["channel"] ||= channel
        end
      end

      def apply_default_excludes
        config["exclude_patterns"] ||= EXCLUDE_PATTERNS
      end
    end
  end
end
