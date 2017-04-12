require "spec_helper"

module CC::CLI
  describe Help do
    describe "#run" do
      it "gives general help when no args" do
        stdout, stderr, exit_code = capture_io_and_exit_code do
          Help.new.run
        end

        expect(exit_code).to eq(0)
        expect(stderr).to be_blank
        expect(stdout).to include("Available commands")
      end

      it "gives specific help for a provided command" do
        stdout, stderr, exit_code = capture_io_and_exit_code do
          Help.new(["analyze"]).run
        end

        expect(exit_code).to eq(0)
        expect(stderr).to be_blank
        expect(stdout).to include("Run analysis")
      end

      it "gives specific help for multiple provided commands" do
        stdout, stderr, exit_code = capture_io_and_exit_code do
          Help.new(["analyze"]).run
        end

        expect(exit_code).to eq(0)
        expect(stderr).to be_blank
        expect(stdout).to include("Run analysis")
      end

      it "warns on unknown commands" do
        stdout, stderr, exit_code = capture_io_and_exit_code do
          Help.new(["analyze", "bogus"]).run
        end

        expect(exit_code).to eq(0)
        expect(stderr).to be_blank
        expect(stdout).to include("Run analysis")
        expect(stdout).to include("Unknown command: bogus")
      end
    end
  end
end
