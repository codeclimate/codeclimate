module CC
  module Analyzer
    class NullContainerLog
      def started(_image)
      end

      def timed_out
      end

      def finished(_status, _stderr)
      end
    end
  end
end
