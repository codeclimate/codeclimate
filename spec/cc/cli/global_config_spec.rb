require "spec_helper"

RSpec.describe CC::CLI::GlobalConfig do
  around(:each) do |example|
    Dir.mktmpdir do |dir|
      ENV["XDG_CONFIG_HOME"] = dir
      example.run
      ENV.delete "XDG_CONFIG_HOME"
    end
  end

  def write_config_file(content)
    dir = File.join(ENV["XDG_CONFIG_HOME"], described_class::NAMESPACE)
    Dir.mkdir dir
    File.write(File.join(dir, described_class::FILE_NAME), content)
  end

  def read_config_file
    File.read File.join(ENV["XDG_CONFIG_HOME"], described_class::NAMESPACE, described_class::FILE_NAME)
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
    config.check_version = false
    config.uuid
    config.save

    expect(read_config_file).to eq "---\ncheck-version: false\nuuid: #{config.uuid}\n"
  end
end
