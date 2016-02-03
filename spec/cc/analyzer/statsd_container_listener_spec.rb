require "spec_helper"

module CC::Analyzer
  describe StatsdContainerListener do
    describe "#started" do
      it "increments a metric in statsd" do
        statsd = double(increment: nil)
        expect(statsd).to receive(:increment).with("engines.started")

        listener = StatsdContainerListener.new("engine", statsd)
        listener.started(nil)
      end
    end

    describe "#timed_out" do
      it "increments a metric in statsd" do
        statsd = double(timing: nil, increment: nil)
        expect(statsd).to receive(:timing).with("engines.time", 10)
        expect(statsd).to receive(:increment).with("engines.result.error")
        expect(statsd).to receive(:increment).with("engines.result.error.timeout")

        listener = StatsdContainerListener.new("engine", statsd)
        listener.timed_out(double(duration: 10))
      end

    end

    describe "#finished" do
      it "increments a metric for success" do
        statsd = double(timing: nil, increment: nil)
        expect(statsd).to receive(:timing).with("engines.time", 10)
        expect(statsd).to receive(:increment).with("engines.finished")
        expect(statsd).to receive(:increment).with("engines.result.success")

        listener = StatsdContainerListener.new("engine", statsd)
        listener.finished(double(duration: 10, status: double(success?: true)))
      end

      it "increments a metric for failure" do
        statsd = double(timing: nil, increment: nil)
        expect(statsd).to receive(:timing).with("engines.time", 10)
        expect(statsd).to receive(:increment).with("engines.finished")
        expect(statsd).to receive(:increment).with("engines.result.error")

        listener = StatsdContainerListener.new("engine", statsd)
        listener.finished(double(duration: 10, status: double(success?: false)))
      end
    end
  end
end
