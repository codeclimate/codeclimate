module CC
  module Analyzer
    class StatsdContainerListener < ContainerListener
      def initialize(statsd)
        @statsd = statsd
      end

      def started(engine, _details)
        increment(engine.name, "started")
      end

      def finished(engine, _details, result)
        timing(engine.name, "time", result.duration)
        increment(engine.name, "finished")

        if result.timed_out?
          timing(engine.name, "time", result.duration)
          increment(engine.name, "result.error")
          increment(engine.name, "result.error.timeout")
        elsif result.maximum_output_exceeded?
          increment(engine.name, "result.error")
          increment(engine.name, "result.error.output_exceeded")
        elsif result.exit_status.nonzero?
          increment(engine.name, "result.error")
        else
          increment(engine.name, "result.success")
        end
      end

      private

      attr_reader :statsd

      def increment(name, metric)
        statsd.increment("engines.#{metric}")
        statsd.increment("engines.names.#{name}.#{metric}")
      end

      def timing(name, metric, ms)
        statsd.timing("engines.#{metric}", ms)
        statsd.timing("engines.names.#{name}.#{metric}", ms)
      end
    end
  end
end
