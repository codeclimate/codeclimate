require "spec_helper"

module CC::CLI
  describe Runner do
    describe ".run" do
      it "rescues exceptions and prints a friendlier message" do
        Explode = Class.new(Command) do
          def run
            raise StandardError, "boom"
          end
        end

        _, stderr = capture_io do
          Runner.run(["explode"])
        end

        stderr.must_match(/error: \(StandardError\) boom/)
      end
    end

    describe "#command_name" do
      it "parses subclasses" do
        Runner.new(["analyze:this"]).command_name.must_equal("Analyze::This")
      end

      it "returns class names" do
        Runner.new(["analyze"]).command_name.must_equal("Analyze")
      end
    end
  end
end
