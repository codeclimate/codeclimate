require "spec_helper"

module CC::Analyzer
  describe EngineProcess do
    describe EngineProcess::EngineTimeout do
      it "can use a class-level message set at runtime" do
        EngineProcess::EngineTimeout.runtime_message = "custom message"

        ex = ->() { fail EngineProcess::EngineTimeout }.must_raise(EngineProcess::EngineTimeout)
        ex.message.must_equal("custom message")
      end
    end
  end
end
