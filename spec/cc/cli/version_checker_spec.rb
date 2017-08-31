require "spec_helper"

describe CC::CLI::VersionChecker do
  around(:each) do |example|
    Dir.mktmpdir do |dir|
      original_config = CC::CLI::GlobalConfig.send :remove_const, :FILE_NAME
      CC::CLI::GlobalConfig.const_set :FILE_NAME, File.join(dir, "config.yml")
      File.write CC::CLI::GlobalConfig::FILE_NAME, "---"

      original_cache = CC::CLI::GlobalCache.send :remove_const, :FILE_NAME
      CC::CLI::GlobalCache.const_set :FILE_NAME, File.join(dir, "cache.yml")
      File.write CC::CLI::GlobalCache::FILE_NAME, "---"

      example.run

      CC::CLI::GlobalConfig.send :remove_const, :FILE_NAME
      CC::CLI::GlobalConfig.const_set :FILE_NAME, original_config

      CC::CLI::GlobalCache.send :remove_const, :FILE_NAME
      CC::CLI::GlobalCache.const_set :FILE_NAME, original_cache
    end
  end

  let(:checker) { described_class.new }

  def stub_version_request(versions_resp)
    stub_resolv("versions.codeclimate.com", "255.255.255.255")

    resp = Net::HTTPOK.new("1.1", 200, "OK")
    allow(resp).to receive(:body).and_return(versions_resp.to_json)
    allow(Net::HTTP).to receive(:start).and_return(resp)
  end

  it "doesn't do anything when disabled in global config" do
    config = CC::CLI::GlobalConfig.new
    config.check_version = false
    config.save

    allow(checker).to receive(:outdated?)

    checker.check

    expect(checker).to_not have_received(:outdated?)
  end

  it "checks version against the API" do
    stub_version_request(latest: "0.1.2", outdated: true)

    _, stderr = capture_io do
      checker.check
    end

    expect(stderr).to include "A new version (v0.1.2) is available"
  end

  it "persistes config" do
    stub_version_request(latest: "0.1.2", outdated: true)
    allow(UUID).to receive(:new).
      and_return(instance_double("UUID", generate: "definitely-a-uuid"))

    config = File.read CC::CLI::GlobalCache::FILE_NAME
    expect(config).to eq "---"

    capture_io do
      checker.check
    end

    config = File.read CC::CLI::GlobalConfig::FILE_NAME
    expect(config).to include "uuid: definitely-a-uuid"
  end

  it "prints nothing when up to date" do
    stub_version_request(latest: "0.1.2", outdated: false)

    _, stderr = capture_io do
      checker.check
    end

    expect(stderr).to eq ""
  end

  it "does nothing when API is unavailable" do
    stub_resolv("versions.codeclimate.com", "255.255.255.255")
    allow(Net::HTTP).to receive(:start).and_return(Net::HTTPServerError.new(500, "Nope", "Nope Nope"))

    cache = CC::CLI::GlobalCache.new
    cache.latest_version = "0.1.1"
    cache.outdated = true

    _, stderr = capture_io do
      checker.check
    end

    expect(stderr).to eq ""
  end

  it "does nothing if checked recently" do
    cache = CC::CLI::GlobalCache.new
    cache.last_version_check = Time.now
    cache.latest_version = "0.1.1"
    cache.outdated = true

    _, stderr = capture_io do
      checker.check
    end

    expect(stderr).to eq ""
  end
end
