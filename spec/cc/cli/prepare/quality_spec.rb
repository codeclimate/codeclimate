require "spec_helper"

describe CC::CLI::Prepare::Quality do
  include FileSystemHelpers
  include ProcHelpers

  around do |spec|
    within_temp_dir { spec.run }
  end

  # Avoid changing to /code when executing
  before { allow(Dir).to receive(:chdir).and_yield }

  it "writes out a config if not present" do
    described_class.new.execute

    expect(File.exist?(CC::CLI::Command::CODECLIMATE_YAML)).to eq true
    expect_maintainability_config(
      SafeYAML.load_file(CC::CLI::Command::CODECLIMATE_YAML)
    )
  end

  it "modifies a config when present" do
    make_file(CC::CLI::Command::CODECLIMATE_YAML, <<-EOYAML)
    engines:
      duplication:
        enabled: true
        channel: stable

    exclude_paths:
    - foo
    - bar
    EOYAML

    described_class.new.execute

    content = SafeYAML.load_file(CC::CLI::Command::CODECLIMATE_YAML)
    expect(content).to have_key("exclude_paths")
    expect_maintainability_config(content)
  end

  it "rescues exceptions and overwrites, with a warning" do
    make_file(CC::CLI::Command::CODECLIMATE_YAML, <<-EOYAML)
    zomg:
      this[isnot]\valid

    [yaml]
    EOYAML

    _stdout, stderr = capture_io { described_class.new.execute }

    expect(stderr).to match(/WARNING/)
    content = SafeYAML.load_file(CC::CLI::Command::CODECLIMATE_YAML)
    expect_maintainability_config(content)
  end

  def expect_maintainability_config(yaml)
    expect(yaml).to have_key("engines")
    expect(yaml.fetch("engines")).to have_key("complexity-ruby")
    expect(yaml.fetch("engines")).to have_key("duplication")
    expect(yaml.fetch("engines").fetch("complexity-ruby").fetch("channel")).to eq "beta"
    expect(yaml.fetch("engines").fetch("duplication").fetch("channel")).to eq "cronopio"
    expect(yaml).not_to have_key("ratings")
  end
end
