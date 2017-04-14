module CC
  module Analyzer
    class CompositeContainerListener < ContainerListener
      def initialize(*listeners)
        @listeners = listeners
      end

      def started(*args)
        listeners.each { |listener| listener.started(*args) }
      end

      def finished(*args)
        listeners.each { |listener| listener.finished(*args) }
      end

      private

      attr_reader :listeners
    end
  end
end
