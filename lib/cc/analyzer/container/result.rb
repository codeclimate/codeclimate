module CC
  module Analyzer
    class Container
      class Result
        attr_reader \
          :container_name,
          :duration,
          :exit_status,
          :output_byte_count,
          :stderr,
          :stdout

        def initialize(
          container_name: "",
          duration: 0,
          exit_status: 0,
          maximum_output_exceeded: false,
          output_byte_count: 0,
          stderr: "",
          stdout: "",
          timed_out: false
        )
          @container_name = container_name
          @duration = duration
          @exit_status = exit_status
          @maximum_output_exceeded = maximum_output_exceeded
          @output_byte_count = output_byte_count
          @stderr = stderr
          @stdout = stdout
          @timed_out = timed_out
        end

        # N.B. This is lossy in that we don't know duration or output_byte_count.
        def self.from_exception(ex)
          new(exit_status: 99, stderr: ex.message)
        end

        def timed_out?
          @timed_out
        end

        def maximum_output_exceeded?
          @maximum_output_exceeded
        end

        def errored?
          timed_out? ||
            maximum_output_exceeded? ||
            exit_status.nil? ||
            exit_status.nonzero?
        end
      end
    end
  end
end
