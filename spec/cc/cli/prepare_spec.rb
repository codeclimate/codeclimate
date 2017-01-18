require "spec_helper"

module CC::CLI
  describe Prepare do
    include FileSystemHelpers
    include ProcHelpers

    FIXTURE_CONFIG = <<YAML
prepare:
  fetch:
  - url: "http://example.com/foo.json"
    path: bar.json
YAML

    around do |test|
      within_temp_dir { test.call }
    end

    describe "#run" do
      it "fetches and writes files" do
        File.write(Command::CODECLIMATE_YAML, FIXTURE_CONFIG)
        resp = double(code: "200", body: "content")

        stub_resp("example.com", "255.255.255.255", resp)
        stdout, stderr = capture_io do
          Prepare.new.run
        end
        expect(stdout).to match("Wrote http://example.com/foo.json to bar.json")

        expect(File.exist?("bar.json")).to eq(true)
        expect(File.read("bar.json")).to eq("content")
      end

      it "fails if address resolves to internal IP" do
        File.write(Command::CODECLIMATE_YAML, FIXTURE_CONFIG)
        resp = double(code: "200", body: "content")

        stub_resp("example.com", "127.0.0.1", resp)
        stdout, stderr, _ = capture_io_and_exit_code do
          Prepare.new.run
        end
        expect(stderr).to match("maps to an internal address")

        expect(File.exist?("bar.json")).to eq(false)
      end

      it "fetches from internal IP if option is given" do
        File.write(Command::CODECLIMATE_YAML, FIXTURE_CONFIG)
        resp = double(code: "200", body: "content")

        stub_resp("example.com", "127.0.0.1", resp)
        stdout, stderr = capture_io do
          Prepare.new(["--allow-internal-ips"]).run
        end
        expect(stdout).to match("Wrote http://example.com/foo.json to bar.json")

        expect(File.exist?("bar.json")).to eq(true)
        expect(File.read("bar.json")).to eq("content")
      end

      it "fails if fetch fails" do
        File.write(Command::CODECLIMATE_YAML, FIXTURE_CONFIG)
        resp = double(code: "404", body: "Not Found")

        stub_resp("example.com", "255.255.255.255", resp)
        stdout, stderr, _ = capture_io_and_exit_code do
          Prepare.new.run
        end
        expect(stderr).to match("Failed fetching")

        expect(File.exist?("bar.json")).to eq(false)
      end
    end
  end
end
