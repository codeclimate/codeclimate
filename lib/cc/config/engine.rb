module CC
  class Config
    class Engine
      DEFAULT_CHANNEL = "stable".freeze
      DUPLICATION_CHANNEL = "cronopio".freeze
      DUPLICATION = "duplication".freeze

      attr_reader :name, :channel, :config
      attr_writer :enabled

      def initialize(name, enabled: false, channel: nil, config: nil)
        @name = name
        @enabled = enabled
        @channel = channel || default_channel
        @config = config || {}
      end

      def enabled?
        @enabled
      end

      def plugin?
        !Default::ENGINE_NAMES.include?(name)
      end

      def container_label
        @container_label ||= SecureRandom.uuid
      end

      def merge(other)
        if eql?(other)
          self.class.new(name, enabled: other.enabled?, channel: other.channel, config: config.deep_merge(other.config))
        else
          raise ArgumentError, "Engine names must match to merge"
        end
      end

      # Set interface methods. Assumes we never want to store the same engine by
      # name in the same list. This should be true except maybe if we want to
      # work with multiple channels at once, which is unlikely.

      def default_channel
        if name == DUPLICATION
          DUPLICATION_CHANNEL
        else
          DEFAULT_CHANNEL
        end
      end

      def eql?(other)
        other.is_a?(self.class) && name.eql?(other.name)
      end

      def hash
        name.hash
      end
    end
  end
end
