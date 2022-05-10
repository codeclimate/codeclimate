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

        stub_resp("http://example.com/foo.json", "255.255.255.255", resp)
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

        stub_resp("http://example.com/foo.json", "127.0.0.1", resp)
        stdout, stderr, _ = capture_io_and_exit_code do
          Prepare.new.run
        end
        expect(stderr).to match("maps to an internal address")

        expect(File.exist?("bar.json")).to eq(false)
      end

      it "fetches from internal IP if option is given" do
        File.write(Command::CODECLIMATE_YAML, FIXTURE_CONFIG)
        resp = double(code: "200", body: "content")

        stub_resp("http://example.com/foo.json", "127.0.0.1", resp)
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

        stub_resp("http://example.com/foo.json", "255.255.255.255", resp)
        stdout, stderr, _ = capture_io_and_exit_code do
          Prepare.new.run
        end
        expect(stderr).to match("Failed fetching")
        expect(stderr).not_to match(resp.body)

        expect(File.exist?("bar.json")).to eq(false)
      end
    end

    def stub_resp(url, addr, resp)
      uri = URI(url)

      stub_resolv(uri.host, addr)

      http = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).with(uri.host, uri.port).and_return(http)
      allow(http).to receive(:get).with(uri).and_return(resp)
      allow(http).to receive(:use_ssl=).with(false)
    end
  end
end
