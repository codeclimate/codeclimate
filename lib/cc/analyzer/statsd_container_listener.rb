module CC
  module Analyzer
    class StatsdContainerListener < ContainerListener
      def initialize(statsd)
        @statsd = statsd
      end

      def started(engine, _details)
        increment(engine.name, engine.channel, "started")
      end

      def finished(engine, _details, result)
        timing(engine.name, engine.channel, "time", result.duration)
        increment(engine.name, engine.channel, "finished")

        if result.timed_out?
          timing(engine.name, engine.channel, "time", result.duration)
          increment(engine.name, engine.channel, "result.error")
          increment(engine.name, engine.channel, "result.error.timeout")
        elsif result.maximum_output_exceeded?
          increment(engine.name, engine.channel, "result.error")
          increment(engine.name, engine.channel, "result.error.output_exceeded")
        elsif result.exit_status.nonzero?
          increment(engine.name, engine.channel, "result.error")
        else
          increment(engine.name, engine.channel, "result.success")
        end
      end

      private

      attr_reader :statsd

      def increment(name, channel, metric)
        statsd.increment("engines.#{metric}")
        statsd.increment("engines.names.#{name}.#{channel}.#{metric}")
      end

      def timing(name, channel, metric, ms)
        statsd.timing("engines.#{metric}", ms)
        statsd.timing("engines.names.#{name}.#{channel}.#{metric}", ms)
      end
    end
  end
end
