require "spec_helper"

module CC::Analyzer
  describe CompositeContainerListener do
    describe "#started" do
      it "delegates to the listeners given" do
        listener_a = double
        listener_b = double

        data = double
        expect(listener_a).to receive(:started).with(data)
        expect(listener_b).to receive(:started).with(data)

        listener = CompositeContainerListener.new(listener_a, listener_b)
        listener.started(data)
      end
    end

    describe "#finished" do
      it "delegates to the listeners given" do
        listener_a = double
        listener_b = double

        data = double
        expect(listener_a).to receive(:finished).with(data)
        expect(listener_b).to receive(:finished).with(data)

        listener = CompositeContainerListener.new(listener_a, listener_b)
        listener.finished(data)
      end
    end
  end
end
