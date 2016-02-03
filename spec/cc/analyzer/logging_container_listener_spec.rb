require "spec_helper"

module CC::Analyzer
  describe LoggingContainerListener do
    describe "#started" do
      it "logs it" do
        logger = double
        listener = LoggingContainerListener.new("foo-engine", logger)

        expect(logger).to receive(:info).with(/foo-engine/)

        listener.started(double)
      end
    end

    describe "#finished" do
      it "logs it" do
        logger = double
        listener = LoggingContainerListener.new("foo-engine", logger)

        expect(logger).to receive(:info).with(/foo-engine/)

        listener.finished(double)
      end
    end
  end
end
