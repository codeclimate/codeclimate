module CC
  module Analyzer
    class NullContainerLog
      def started(_image, _name)
      end

      def timed_out(_image, _name, _seconds)
      end

      def finished(_image, _name, _status, _stderr)
      end
    end
  end
end
