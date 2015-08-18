require "spec_helper"

module CC::Analyzer
  describe CompositeContainerListener do
    describe "#started" do
      it "delegates to the listeners given" do
        listener_a = stub
        listener_b = stub

        data = stub
        listener_a.expects(:started).with(data)
        listener_b.expects(:started).with(data)

        listener = CompositeContainerListener.new(listener_a, listener_b)
        listener.started(data)
      end
    end

    describe "#timed_out" do
      it "delegates to the listeners given" do
        listener_a = stub
        listener_b = stub

        data = stub
        listener_a.expects(:timed_out).with(data)
        listener_b.expects(:timed_out).with(data)

        listener = CompositeContainerListener.new(listener_a, listener_b)
        listener.timed_out(data)
      end
    end

    describe "#finished" do
      it "delegates to the listeners given" do
        listener_a = stub
        listener_b = stub

        data = stub
        listener_a.expects(:finished).with(data)
        listener_b.expects(:finished).with(data)

        listener = CompositeContainerListener.new(listener_a, listener_b)
        listener.finished(data)
      end
    end
  end
end
