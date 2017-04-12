module CC
  module Config
    class Engine
      DEFAULT_CHANNEL = "stable".freeze

      attr_reader :name, :channel, :config

      def initialize(name, enabled: false, channel: DEFAULT_CHANNEL, config: {})
        @name = name
        @enabled = enabled
        @channel = channel
        @config = config
      end

      def enabled?
        @enabled
      end

      def container_label
        @container_label ||= SecureRandom.uuid
      end

      def to_config_json
        {
          "channel" => channel,
          "config" => config,
        }
      end
    end
  end
end
