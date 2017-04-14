module CC
  module Analyzer
    class LoggingContainerListener < ContainerListener
      def initialize(logger)
        @logger = logger
      end

      def started(engine, _details)
        logger.info("starting engine #{engine.name}")
      end

      def finished(engine, _details, _result)
        logger.info("finished engine #{engine.name}")
      end

      private

      attr_reader :logger
    end
  end
end
