module CC
  class Config
    class Engine
      DEFAULT_CHANNEL = "stable".freeze

      attr_accessor :channel
      attr_reader :name, :config, :exclude_patterns
      attr_writer :enabled

      def initialize(name, enabled: false, channel: nil, config: nil, exclude_patterns: [])
        @name = name
        @enabled = enabled
        @channel = channel || DEFAULT_CHANNEL
        @config = config || {}
        @exclude_patterns = exclude_patterns
      end

      def enabled?
        @enabled
      end

      def plugin?
        !DefaultAdapter::ENGINES.keys.include?(name)
      end

      def container_label
        @container_label ||= SecureRandom.uuid
      end

      def hash
        name.hash
      end

      def eql?(other)
        other.is_a?(self.class) && name.eql?(other.name)
      end
      alias_method :==, :eql?
      alias_method :equal?, :eql?
    end
  end
end
