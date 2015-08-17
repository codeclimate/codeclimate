require "spec_helper"

module CC::Analyzer
  describe StatsdContainerListener do
    describe "#started" do
      it "increments a metric in statsd" do
        statsd = stub(increment: nil)
        statsd.expects(:increment).with("engines.started")

        listener = StatsdContainerListener.new("engine", statsd)
        listener.started(nil)
      end
    end

    describe "#timed_out" do
      it "increments a metric in statsd" do
        statsd = stub(timing: nil, increment: nil)
        statsd.expects(:timing).with("engines.time", 10)
        statsd.expects(:increment).with("engines.result.error")
        statsd.expects(:increment).with("engines.result.error.timeout")

        listener = StatsdContainerListener.new("engine", statsd)
        listener.timed_out(stub(duration: 10))
      end

    end

    describe "#finished" do
      it "increments a metric for success" do
        statsd = stub(timing: nil, increment: nil)
        statsd.expects(:timing).with("engines.time", 10)
        statsd.expects(:increment).with("engines.finished")
        statsd.expects(:increment).with("engines.result.success")

        listener = StatsdContainerListener.new("engine", statsd)
        listener.finished(stub(duration: 10, status: stub(success?: true)))
      end

      it "increments a metric for failure" do
        statsd = stub(timing: nil, increment: nil)
        statsd.expects(:timing).with("engines.time", 10)
        statsd.expects(:increment).with("engines.finished")
        statsd.expects(:increment).with("engines.result.error")

        listener = StatsdContainerListener.new("engine", statsd)
        listener.finished(stub(duration: 10, status: stub(success?: false)))
      end
    end
  end
end
