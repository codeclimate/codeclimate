require "spec_helper"

module CC::Analyzer
  describe RaisingContainerListener do
    describe "#timed_out" do
      it "raises the given timeout exception" do
        timeout_ex = Class.new(StandardError)
        listener = RaisingContainerListener.new("engine", nil, timeout_ex)

        expect { listener.timed_out(double(duration: 900000)) }.to raise_error(
          timeout_ex, /engine ran for 900 seconds/
        )
      end
    end

    describe "#error" do
      it "does nothing on success" do
        listener = RaisingContainerListener.new("engine", nil, nil)
        listener.finished(double(status: double(success?: true), stderr: ""))
      end

      it "raises the given error exception on error" do
        error_ex = Class.new(StandardError)
        listener = RaisingContainerListener.new("engine", error_ex, nil)
        data = double(
          status: double(success?: false, exitstatus: 1),
          stderr: "some error",
        )

        expect { listener.finished(data) }.to raise_error(
          error_ex, /engine errored.*status 1.*some error/m

        )
      end
    end
  end
end
