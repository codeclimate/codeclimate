require "spec_helper"

describe CC::CLI::GlobalCache do
  around(:each) do |example|
    Dir.mktmpdir do |dir|
      original_file_name = described_class.send :remove_const, :FILE_NAME
      described_class.const_set :FILE_NAME, File.join(dir, "cache.yml")
      write_cache_file "---"
      example.run
      described_class.send :remove_const, :FILE_NAME
      described_class.const_set :FILE_NAME, original_file_name
    end
  end

  def write_cache_file(content)
    File.write(described_class::FILE_NAME, content)
  end

  def read_cache_file
    File.read described_class::FILE_NAME
  end

  let(:cache) { described_class.new }

  it "loads cache" do
    write_cache_file("---\nlatest-version: 42")

    expect(cache.latest_version).to eq 42
  end

  describe "latest_version" do
    it "autosaves cache on assignment" do
      cache.latest_version = 42

      expect(read_cache_file).to include "latest-version: 42"
    end

    it "return epoch start by default" do
      expect(cache.last_version_check).to eq Time.at(0)
    end
  end

  describe "last_version_check" do
    it "resets to epoch start when non-time vallue is assigned" do
      time = Time.now

      cache.last_version_check = time
      expect(cache.last_version_check).to eq time

      cache.last_version_check = "nope"
      expect(cache.last_version_check).to eq Time.at(0)
    end

    it "autosaves on assignment" do
      time = Time.now

      cache.last_version_check = time
      expect(read_cache_file).to include "last-version-check: #{time.strftime "%F %T.%N %:z"}"
    end
  end

  describe "outdated" do
    it "returns false by default" do
      expect(cache.outdated).to eq false
    end

    it "autosaves on assignment" do
      cache.outdated = true
      expect(read_cache_file).to include "outdated: true"
    end

    it "converts assigned value to boolean" do
      cache.outdated = 42
      expect(cache.outdated).to eq false
    end

    it "is aliased as outdated?" do
      cache.outdated = true
      expect(cache.outdated).to eq true
      expect(cache.outdated?).to eq true

      cache.outdated = false
      expect(cache.outdated).to eq false
      expect(cache.outdated?).to eq false
    end
  end
end
