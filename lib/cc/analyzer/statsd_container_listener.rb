module CC
  module Analyzer
    class StatsdContainerListener < ContainerListener
      # rubocop:disable Lint/MissingSuper
      def initialize(statsd, repo_id: nil)
        @statsd = statsd
        @repo_id = repo_id
      end
      # rubocop:enable Lint/MissingSuper

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

      attr_reader :statsd, :repo_id

      def increment(engine, action)
        tags = engine_tags(engine)
        metric = metric_name(action)

        # rubocop:disable Style/HashSyntax
        statsd.increment(metric, tags: tags)
        # rubocop:enable Style/HashSyntax
      end

      def timing(engine, action, millis)
        tags = engine_tags(engine)
        metric = metric_name(action)

        # rubocop:disable Style/HashSyntax
        statsd.timing(metric, millis, tags: tags)
        # rubocop:enable Style/HashSyntax
      end

      def metric_name(action)
        "engines.#{action}"
      end

      def engine_tags(engine)
        ["engine:#{engine.name}"].tap do |tags|
          tags << "channel:#{engine.channel}" if engine_channel_present?(engine)
          tags << "repo_id:#{repo_id}" if repo_id.present?
        end
      end

      def engine_channel_present?(engine)
        engine.respond_to?(:channel) && engine.channel
      end
    end
  end
end
