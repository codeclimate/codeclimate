module CC
  module Analyzer
    class LoggingContainerListener < ContainerListener
      def initialize(engine_name, logger)
        @engine_name = engine_name
        @logger = logger
      end

      def started(_data)
        logger.info("starting engine #{engine_name}")
      end

      def finished(_data)
        logger.info("finished engine #{engine_name}")
      end

      private

      attr_reader :engine_name, :logger
    end
  end
end
