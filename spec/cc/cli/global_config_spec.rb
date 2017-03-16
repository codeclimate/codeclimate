require "spec_helper"

describe CC::CLI::GlobalConfig do
  around(:each) do |example|
    Dir.mktmpdir do |dir|
      original_file_name = described_class.send :remove_const, :FILE_NAME
      described_class.const_set :FILE_NAME, File.join(dir, "config.yml")
      example.run
      described_class.send :remove_const, :FILE_NAME
      described_class.const_set :FILE_NAME, original_file_name
    end
  end

  def write_config_file(content)
    File.write described_class::FILE_NAME, content
  end

  def read_config_file
    File.read described_class::FILE_NAME
  end

  let(:config) { described_class.new }

  it "generates a UUID for you" do
    allow(UUID).to receive(:new).
      and_return(instance_double("UUID", generate: "definitely-a-uuid"))

    expect(config.uuid).to eq "definitely-a-uuid"
  end

  it "check_version is true by default" do
    expect(config.check_version).to eq true
  end

  it "check_version? is an alias to check_version" do
    expect(config.check_version).to eq true
    expect(config.check_version?).to eq true

    config.check_version = false

    expect(config.check_version).to eq false
    expect(config.check_version?).to eq false
  end

  it "loads config" do
    write_config_file("---\ncheck-version: false\nuuid: uuid")

    expect(config.check_version?).to eq false
    expect(config.uuid).to eq "uuid"
  end

  it "saves config" do
    write_config_file("---")
    config.check_version = false
    config.uuid
    config.save

    expect(read_config_file).to eq "---\ncheck-version: false\nuuid: #{config.uuid}\n"
  end
end
