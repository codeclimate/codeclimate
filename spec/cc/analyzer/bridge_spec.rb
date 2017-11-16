require "spec_helper"

describe CC::Analyzer::Bridge do
  include FileSystemHelpers

  around do |test|
    within_temp_dir { test.call }
  end

  describe "#run" do
    it "runs an engine" do
      make_tree <<-EOFILES
        foo/thing.rb
        foo/bar.rb
        bar/baz.rb
      EOFILES

      write_cc_yaml(YAML.dump(
        "plugins" => { "foo" => true },
        "exclude_patterns" => ["bar/"],
      ))

      expect_engine_run(
        "structure",
        { "image" => "structure-stable", "command" => nil },
        {
          "enabled" => true,
          "channel" => "stable",
          "include_paths" => match_array(["foo/", ".codeclimate.yml", "engines.yml"]),
        },
      )
      expect_engine_run(
        "duplication",
        { "image" => "duplication:cronopio", "command" => nil },
        {
          "enabled" => true,
          "channel" => "cronopio",
          "include_paths" => match_array(["foo/", ".codeclimate.yml", "engines.yml"]),
        },
      )
      expect_engine_run(
        "foo",
        { "image" => "foo-stable", "command" => nil },
        {
          "enabled" => true,
          "channel" => "stable",
          "include_paths" => match_array(["foo/", ".codeclimate.yml", "engines.yml"]),
        },
      )

      described_class.new(
        config: CC::Config.load,
        formatter: stub_formatter,
        listener: stub_listener,
        registry: engine_registry,
      ).run
    end

    it "runs engines, respecting engine exclude_patterns" do
      make_tree <<-EOFILES
        foo/thing.rb
        foo/bar.rb
        bar/baz.rb
      EOFILES

      write_cc_yaml(YAML.dump(
        "plugins" => {
          "foo" => { "exclude_patterns" => ["**/*r.rb"] },
          "bar" => { "enabled" => true, "channel" => "beta" },
        },
        "exclude_patterns" => ["bar/"]
      ))

      expect_engine_run(
        "structure",
        { "image" => "structure-stable", "command" => nil },
        {
          "enabled" => true,
          "channel" => "stable",
          "include_paths" => match_array(["foo/", ".codeclimate.yml", "engines.yml"]),
        },
      )
      expect_engine_run(
        "duplication",
        { "image" => "duplication:cronopio", "command" => nil },
        {
          "enabled" => true,
          "channel" => "cronopio",
          "include_paths" => match_array(["foo/", ".codeclimate.yml", "engines.yml"]),
        },
      )
      expect_engine_run(
        "foo",
        { "image" => "foo-stable", "command" => nil },
        {
          "exclude_patterns" => ["**/*r.rb"],
          "channel" => "stable",
          "include_paths" => match_array(["foo/thing.rb", ".codeclimate.yml", "engines.yml"]),
        },
      )
      expect_engine_run(
        "bar",
        { "image" => "bar:beta", "command" => nil },
        {
          "enabled" => true,
          "channel" => "beta",
          "include_paths" => match_array(["foo/", ".codeclimate.yml", "engines.yml"]),
        },
      )

      described_class.new(
        config: CC::Config.load,
        formatter: stub_formatter,
        listener: stub_listener,
        registry: engine_registry,
      ).run
    end
  end

  def write_cc_yaml(yaml)
    File.write(CC::Config::YAMLAdapter::DEFAULT_PATH, yaml)
  end

  def engine_registry
    File.write("engines.yml", <<-EOYAML)
    structure:
      channels:
        stable: structure-stable
    duplication:
      channels:
        stable: duplication-stable
        cronopio: "duplication:cronopio"
    foo:
      channels:
        stable: foo-stable
    bar:
      channels:
        stable: bar-stable
        beta: "bar:beta"
    EOYAML
    CC::EngineRegistry.new("engines.yml")
  end

  def expect_engine_run(name, metadata, config)
    engine_double = double("engine_#{name}")
    expect(CC::Analyzer::Engine).to receive(:new).with(
      name,
      metadata,
      config,
      instance_of(String),
    ).and_return(engine_double)
    expect(engine_double).to receive(:run).once
  end

  def stub_formatter
    double(:formatter).tap do |stub|
      expect(stub).to receive(:started).once
      expect(stub).to receive(:engine_running).at_least(:once).and_yield
      expect(stub).to receive(:finished).once
      expect(stub).to receive(:close).once
    end
  end

  def stub_listener
    double(:listener).tap do |stub|
      expect(stub).to receive(:started).at_least(:once)
      expect(stub).to receive(:finished).at_least(:once)
    end
  end
end
