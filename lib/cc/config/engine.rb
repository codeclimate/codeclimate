module CC
  module Config
    class Engine
      DEFAULT_CHANNEL = "stable".freeze

      attr_reader :name, :channel, :config
      attr_writer :enabled

      def initialize(name, enabled: false, channel: nil, config: nil)
        @name = name
        @enabled = enabled
        @channel = channel || DEFAULT_CHANNEL
        @config = config || {}
      end

      def enabled?
        @enabled
      end

      def container_label
        @container_label ||= SecureRandom.uuid
      end

      # Set interface methods. Assumes we never want to store the same engine by
      # name in the same list. This should be true except maybe if we want to
      # work with multiple channels at once, which is unlikely.

      def eql?(other)
        other.is_a?(self.class) && name.eql?(other.name)
      end

      def hash
        name.hash
      end
    end
  end
end
