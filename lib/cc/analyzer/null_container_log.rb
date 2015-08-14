module CC
  module Analyzer
    class NullContainerLog
      def started(_image, _name)
      end

      def timed_out(_seconds)
      end

      def finished(_status, _stderr)
      end
    end
  end
end
