module CC
  module Analyzer
    class ContainerListener
      def started(_engine, _details); end

      def finished(_engine, _details, _result); end
    end
  end
end
