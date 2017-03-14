require "spec_helper"

module CC::CLI
  describe Runner do
    before do
      versions_resp = { version: "0.4.1" }
      resp = double(code: "200", body: versions_resp.to_json)
      stub_resp("versions.codeclimate.com", "255.255.255.255", resp)
    end

    describe ".run" do
      it "rescues exceptions and prints a friendlier message" do
        checker = instance_double("Version checker")
        allow(VersionChecker).to receive(:new).and_return(checker)
        allow(checker).to receive(:check)

        Explode = Class.new(Command) do
          def run
            raise StandardError, "boom"
          end
        end

        _, stderr = capture_io do
          Runner.run(["explode"])
        end

        expect(stderr).to match(/error: \(StandardError\) boom/)
      end

      it "doesn't check for new version when --no-check-version is passed" do
        checker = instance_double("Version checker")
        allow(VersionChecker).to receive(:new).and_return(checker)
        allow(checker).to receive(:check)

        ARGV.unshift("--no-check-version")
        capture_io do
          Runner.run([])
        end

        expect(checker).to_not have_received(:check)
      end

      it "checks for new version by default" do
        checker = instance_double("Version checker")
        allow(VersionChecker).to receive(:new).and_return(checker)
        allow(checker).to receive(:check)

        capture_io do
          Runner.run([])
        end

        expect(checker).to have_received(:check)
      end
    end

    describe "#command_class" do
      it "resolves command class from arguments" do
        Hello = Class.new(Command)

        expect(Runner.new(["hello"]).command_class).to eq ::CC::CLI::Hello
      end

      it "resolves namespaced command class from arguments" do
        module World
          Hello = Class.new(Command)
        end

        expect(Runner.new(["world:hello"]).command_class)
          .to eq ::CC::CLI::World::Hello
      end
    end

    describe "#command" do
      {
        [nil, "-h", "-?", "--help"] => "help",
        ["-v", "--version"] => "version"
      }.each do |args, command|
        args.each do |arg|
          it "maps #{arg} to #{command}" do
            expect(Runner.new([arg]).command).to eq command
          end
        end
      end
    end
  end
end
