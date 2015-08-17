module CC
  module Analyzer
    class StatsdContainerListener < ContainerListener
      def initialize(engine_name, statsd)
        @engine_name = engine_name
        @statsd = statsd
      end

      def started(_data)
        increment("started")
      end

      def timed_out(data)
        timing("time", data.duration)
        increment("result.error")
        increment("result.error.timeout")
      end

      def finished(data)
        timing("time", data.duration)
        increment("finished")

        if data.status.success?
          increment("result.success")
        else
          increment("result.error")
        end
      end

      private

      attr_reader :engine_name, :statsd

      def increment(metric)
        statsd.increment("engines.#{metric}")
        statsd.increment("engines.names.#{engine_name}.#{metric}")
      end

      def timing(metric, ms)
        statsd.timing("engines.#{metric}", ms)
        statsd.timing("engines.names.#{engine_name}.#{metric}", ms)
      end
    end
  end
end
