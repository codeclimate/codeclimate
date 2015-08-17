module CC
  module Analyzer
    class ContainerListener
      ContainerData = Struct.new(
        :image,         # image used to create the container
        :name,          # name given to the container when created
        :duration,      # duration, for a finished event
        :status,        # status, for a finished event
        :stderr,        # stderr, for a finished event
      )

      def started(_data)
      end

      def timed_out(_data)
      end

      def finished(_data)
      end
    end
  end
end
