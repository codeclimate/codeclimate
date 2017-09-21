require "cc/analyzer"

module CC
  module CLI
    module Engines
      class EngineCommand < Command
        abstract!

        def engine_registry
          @engine_registry ||= EngineRegistry.new
        end
      end
    end
  end
end
