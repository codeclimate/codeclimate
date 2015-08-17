require "spec_helper"

module CC::Analyzer
  describe RaisingContainerListener do
    describe "#timed_out" do
      it "raises the given timeout exception" do
        timeout_ex = Class.new(StandardError)
        listener = RaisingContainerListener.new("engine", nil, timeout_ex)

        ex = ->() { listener.timed_out(stub(duration: 10)) }.must_raise(timeout_ex)
        ex.message.must_match /engine ran for 10 seconds/
      end
    end

    describe "#failure" do
      it "does nothing on success" do
        listener = RaisingContainerListener.new("engine", nil, nil)
        listener.finished(stub(status: stub(success?: true), stderr: ""))
      end

      it "raises the given failure exception on error" do
        failure_ex = Class.new(StandardError)
        listener = RaisingContainerListener.new("engine", failure_ex, nil)
        data = stub(
          status: stub(success?: false, exitstatus: 1),
          stderr: "some error",
        )

        ex = ->() { listener.finished(data) }.must_raise(failure_ex)
        ex.message.must_match /engine failed/
        ex.message.must_match /status 1/
        ex.message.must_match /some error/
      end
    end
  end
end
