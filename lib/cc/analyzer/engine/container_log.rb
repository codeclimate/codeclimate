module CC
  module Analyzer
    class Engine
      EngineFailure = Class.new(StandardError)
      EngineTimeout = Class.new(StandardError)

      class ContainerLog
        def initialize(name, inner_log)
          @name = name
          @inner_log = inner_log
        end

        def started(image, name)
          @inner_log.started(image, name)

          Analyzer.statsd.increment("cli.engines.started")
        end

        def timed_out(timeout)
          @inner_log.timed_out(timeout)

          Analyzer.statsd.increment("cli.engines.result.error")
          Analyzer.statsd.increment("cli.engines.result.error.timeout")
          Analyzer.statsd.increment("cli.engines.names.#{@name}.result.error")
          Analyzer.statsd.increment("cli.engines.names.#{@name}.result.error.timeout")

          raise EngineTimeout, "engine #{@name} ran past #{timeout} seconds and was killed"
        end

        def finished(status, stderr)
          @inner_log.finished(status, stderr)

          Analyzer.statsd.increment("cli.engines.finished")

          if status.success?
            Analyzer.statsd.increment("cli.engines.result.success")
            Analyzer.statsd.increment("cli.engines.names.#{@name}.result.success")
          else
            Analyzer.statsd.increment("cli.engines.result.error")
            Analyzer.statsd.increment("cli.engines.names.#{@name}.result.error")

            raise EngineFailure, "engine #{@name} failed with status #{status.exitstatus} and stderr \n#{stderr}"
          end
        end
      end
    end
  end
end
