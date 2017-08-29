module CC
  module CLI
    class Analyze < Command
      class EngineFailure < StandardError
        def initialize(message, _engine_name)
          super(message)
        end
      end
    end
  end
end
