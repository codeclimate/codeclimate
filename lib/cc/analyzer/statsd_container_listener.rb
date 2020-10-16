module CC
  module Analyzer
    class StatsdContainerListener < ContainerListener
      def initialize(statsd)
        @statsd = statsd
      end

      def started(engine, _details)
        increment(engine, "started")
      end

      def finished(engine, _details, result)
        timing(engine, "time", result.duration)
        increment(engine, "finished")

        if result.timed_out?
          timing(engine, "time", result.duration)
          increment(engine, "result.error")
          increment(engine, "result.error.timeout")
        elsif result.maximum_output_exceeded?
          increment(engine, "result.error")
          increment(engine, "result.error.output_exceeded")
        elsif result.exit_status.nonzero?
          increment(engine, "result.error")
        else
          increment(engine, "result.success")
        end
      end

      private

      attr_reader :statsd

      def increment(engine, metric)
        statsd.increment("engines.#{metric}")
        statsd.increment("engines.names.#{engine.name}.#{metric}")
        if engine.respond_to?(:channel) && engine.channel
          statsd.increment("engines.names.#{engine.name}.#{engine.channel}.#{metric}")
        end
      end

      def timing(engine, metric, millis)
        statsd.timing("engines.#{metric}", millis)
        statsd.timing("engines.names.#{engine.name}.#{metric}", millis)
        if engine.respond_to?(:channel) && engine.channel
          statsd.timing("engines.names.#{engine.name}.#{engine.channel}.#{metric}", millis)
        end
      end
    end
  end
end
