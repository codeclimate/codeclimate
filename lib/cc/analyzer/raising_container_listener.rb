module CC
  module Analyzer
    class RaisingContainerListener < ContainerListener
      def initialize(engine_name, error_ex, timeout_ex)
        @engine_name = engine_name
        @error_ex = error_ex
        @timeout_ex = timeout_ex
      end

      def timed_out(data)
        message = "engine #{engine_name} ran for #{data.duration / 1000} seconds"
        message << " and was killed"

        raise timeout_ex, message
      end

      def finished(data)
        unless data.status.success?
          message = "engine #{engine_name} errored"
          message << " with status #{data.status.exitstatus}"
          message << " and stderr \n#{data.stderr}"

          raise error_ex, message
        end
      end

      private

      attr_reader :engine_name, :error_ex, :timeout_ex
    end
  end
end
