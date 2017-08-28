module CC
  module Analyzer
    class RaisingContainerListener < ContainerListener
      def initialize(failure_ex, timeout_ex = nil, maximum_output_ex = nil)
        @failure_ex = failure_ex
        @timeout_ex = timeout_ex || failure_ex
        @maximum_output_ex = maximum_output_ex || failure_ex
      end

      def finished(engine, _details, result)
        if result.timed_out?
          message = "engine #{engine.name} ran for #{result.duration / 1000}"
          message << " seconds and was killed"
          raise timeout_ex.new(message, engine.name)
        elsif result.maximum_output_exceeded?
          message = "engine #{engine.name} produced too much output"
          message << " (#{result.output_byte_count} bytes)"
          raise maximum_output_ex.new(message, engine.name)
        elsif result.exit_status.nonzero?
          message = "engine #{engine.name} failed"
          message << " with status #{result.exit_status}"
          message << " and stderr \n#{result.stderr}"
          raise failure_ex.new(message, engine.name)
        end
      end

      private

      attr_reader :failure_ex, :timeout_ex, :maximum_output_ex
    end
  end
end
