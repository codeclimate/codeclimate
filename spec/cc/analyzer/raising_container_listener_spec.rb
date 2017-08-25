require "spec_helper"

module CC::Analyzer
  describe RaisingContainerListener do
    class EngineError < StandardError
      def initialize(message, engine_name)
        @engine_name = engine_name
        super message
      end
    end

    let(:engine) { double(name: "engine") }

    describe "#failure" do
      it "does nothing on success" do
        result = double(timed_out?: false, maximum_output_exceeded?: false, exit_status: 0)

        listener = RaisingContainerListener.new(nil)
        listener.finished(engine, nil, result)
      end

      it "raises the given failure exception on error" do
        result = double(
          timed_out?: false,
          maximum_output_exceeded?: false,
          exit_status: 1,
          stderr: "some error",
        )
        failure_ex = Class.new(EngineError)

        listener = RaisingContainerListener.new(failure_ex)

        expect { listener.finished(engine, nil, result) }.to raise_error(
          failure_ex, /engine failed.*status 1.*some error/m
        )
      end


      it "raises the given timeout exception" do
        result = double(
          timed_out?: true,
          duration: 900000,
        )
        timeout_ex = Class.new(EngineError)
        listener = RaisingContainerListener.new(nil, timeout_ex)

        expect { listener.finished(engine, nil, result) }.to raise_error(
          timeout_ex, /engine ran for 900 seconds/
        )
      end

      it "raises the given maximum output exception" do
        result = instance_double("Result",
          timed_out?: false,
          maximum_output_exceeded?: true,
          output_byte_count: 857,
        )
        message = "engine produced too much output. 857 bytes"
        expection = instance_double("Expception")
        maximum_output_ex = Class.new(EngineError)

        listener = RaisingContainerListener.new(nil, nil, maximum_output_ex)

        expect { listener.finished(engine, nil, result) }.to raise_error(
          maximum_output_ex, /engine produced too much output.*857/
        )
      end
    end
  end
end
