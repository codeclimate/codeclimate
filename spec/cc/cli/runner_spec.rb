require "spec_helper"

module CC::CLI
  describe Runner do
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
