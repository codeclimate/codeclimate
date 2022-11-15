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

      def increment(engine, metric_name)
        tags = engine_tags(engine)
        # rubocop:disable Style/HashSyntax
        metrics(engine, metric_name).each { |metric| statsd.increment(metric, tags: tags) }
        # rubocop:enable Style/HashSyntax
      end

      def timing(engine, metric_name, millis)
        tags = engine_tags(engine)
        # rubocop:disable Style/HashSyntax
        metrics(engine, metric_name).each { |metric| statsd.timing(metric, millis, tags: tags) }
        # rubocop:enable Style/HashSyntax
      end

      def metrics(engine, metric_name)
        [
          "engines.#{metric_name}",
          "engines.names.#{engine.name}.#{metric_name}",
        ].tap do |metrics|
          metrics << "engines.names.#{engine.name}.#{engine.channel}.#{metric_name}" if engine_channel_present?(engine)
        end
      end

      def engine_tags(engine)
        ["engine:#{engine.name}"].tap do |tags|
          tags << "channel:#{engine.channel}" if engine_channel_present?(engine)
        end
      end

      def engine_channel_present?(engine)
        engine.respond_to?(:channel) && engine.channel
      end
    end
  end
end
