module CC
  module Analyzer
    class CompositeContainerListener < ContainerListener
      def initialize(*listeners)
        @listeners = listeners
      end

      def started(data)
        listeners.each { |listener| listener.started(data) }
      end

      def timed_out(data)
        listeners.each { |listener| listener.timed_out(data) }
      end

      def finished(data)
        listeners.each { |listener| listener.finished(data) }
      end

      private

      attr_reader :listeners
    end
  end
end
