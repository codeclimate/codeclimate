module CC
  module Analyzer
    class Engine
      class EngineFailure < StandardError
        attr_reader :details

        def initialize(message, details = nil)
          super(message)
          @details = details
        end
      end

      EngineTimeout = Class.new(StandardError)
      OutputInvalid = Class.new(EngineFailure)
      IssueInvalid = Class.new(EngineFailure)
    end
  end
end
