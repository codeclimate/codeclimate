require "spec_helper"

module CC::Analyzer
  describe LoggingContainerListener do
    let(:engine) { double(name: "engine") }

    describe "#started" do
      it "logs it" do
        logger = double
        listener = LoggingContainerListener.new(logger)

        expect(logger).to receive(:info).with(/starting engine engine/)

        listener.started(engine, nil)
      end
    end

    describe "#finished" do
      it "logs it" do
        logger = double
        listener = LoggingContainerListener.new(logger)

        expect(logger).to receive(:info).with(/finished engine engine/)

        listener.finished(engine, nil, double(:result, skipped?: false))
      end

      it "warns about skip" do
        logger = double
        listener = LoggingContainerListener.new(logger)

        expect(logger).to receive(:info).with(/finished engine engine/)
        expect(logger).to receive(:warn).with(/skipped engine engine/)

        listener.finished(engine, nil, double(:result, skipped?: true, stderr: "foo"))
      end
    end
  end
end
