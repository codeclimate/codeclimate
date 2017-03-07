require "spec_helper"

describe CC::CLI::VersionChecker do
  let(:checker) { described_class.new }

  def stub_version_request(versions_resp)
    stub_resolv("versions.codeclimate.com", "255.255.255.255")

    resp = Net::HTTPOK.new("1.1", 200, "OK")
    allow(resp).to receive(:body).and_return(versions_resp.to_json)
    allow(Net::HTTP).to receive(:start).and_return(resp)
  end

  it "checks version against the API" do
    stub_version_request(latest: "0.1.2", outdated: true)

    out, = capture_io do
      checker.check
    end

    expect(out).to include "A new version (v0.1.2) is available"
  end

  it "prints nothing when up to date" do
    stub_version_request(latest: "0.1.2", outdated: false)

    out, = capture_io do
      checker.check
    end

    expect(out).to eq ""
  end

  it "uses default values when API is unavailable" do
    stub_resolv("versions.codeclimate.com", "255.255.255.255")
    allow(Net::HTTP).to receive(:start).and_return(Net::HTTPServerError.new(500, "Nope", "Nope Nope"))

    out, = capture_io do
      checker.check
    end

    expect(out).to eq ""
  end
end
