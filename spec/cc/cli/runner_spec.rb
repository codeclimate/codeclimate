require "spec_helper"

module CC::CLI
  describe Runner do
    before do
      versions_resp = { version: "0.4.1" }
      resp = double(code: "200", body: versions_resp.to_json)
      stub_resp("https://versions.codeclimate.com", "255.255.255.255", resp)
    end

    describe ".run" do
      it "prints help when no command is passed" do
        stdout, stderr, exit_code = capture_io_and_exit_code do
          Runner.run([])
        end

        expect(exit_code).to eq(0)
        expect(stderr).to be_blank
        expect(stdout).to include("Available commands")
      end

      it "rescues exceptions and prints a friendlier message" do
        checker = instance_double("Version checker")
        allow(VersionChecker).to receive(:new).and_return(checker)
        allow(checker).to receive(:check)

        Explode = Class.new(Command) do
          def run
            raise StandardError, "boom"
          end
        end

        _, stderr, exit_code = capture_io_and_exit_code do
          Runner.run(["explode"])
        end

        expect(stderr).to match(/error: \(StandardError\) boom/)
        expect(exit_code).to eq(1)
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

    def stub_resp(url, addr, resp)
      uri = URI(url)

      stub_resolv(uri.host, addr)

      http = instance_double(Net::HTTP)
      allow(http).to receive(:open_timeout=)
      allow(http).to receive(:read_timeout=)
      allow(http).to receive(:ssl_timeout=)
      allow(http).to receive(:use_ssl=)
      allow(http).to receive(:get).and_return(resp)

      allow(Net::HTTP).to receive(:new).and_return(http)
    end
  end
end
