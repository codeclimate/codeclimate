require "spec_helper"

module CC::Analyzer
  describe LoggingContainerListener do
    describe "#started" do
      it "logs it" do
        logger = stub
        listener = LoggingContainerListener.new("foo-engine", logger)

        logger.expects(:info).with { |msg| msg.must_match /foo-engine/ }

        listener.started(stub)
      end
    end

    describe "#finished" do
      it "logs it" do
        logger = stub
        listener = LoggingContainerListener.new("foo-engine", logger)

        logger.expects(:info).with { |msg| msg.must_match /foo-engine/ }

        listener.finished(stub)
      end
    end
  end
end
