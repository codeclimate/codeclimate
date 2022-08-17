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
          skipped: false,
          stderr: "",
          stdout: "",
          timed_out: false
        )
          @container_name = container_name
          @duration = duration
          @exit_status = exit_status
          @maximum_output_exceeded = maximum_output_exceeded
          @output_byte_count = output_byte_count
          @skipped = skipped
          @stderr = stderr
          @stdout = stdout
          @timed_out = timed_out
        end

        def self.skipped(exception)
          new(
            exit_status: 0,
            skipped: true,
            stderr: exception.message,
          )
        end

        def merge_from_exception(exception)
          self.exit_status = 99
          self.stderr = exception.message
          self
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

        def skipped?
          @skipped
        end

        private

        attr_writer :exit_status, :stderr
      end
    end
  end
end
