require "spec_helper"

describe CC::EngineRegistry do
  describe "#fetch_engine_details" do
    it "returns engine details" do
      registry = registry_from_yaml(<<-EOYAML)
      rubocop:
        channels:
          stable: foo
          example: bar
      EOYAML

      engine = double(name: "rubocop", channel: "example")
      engine_details = registry.fetch_engine_details(engine)

      expect(engine_details.image).to eq("bar")
      expect(engine_details.command).to be_nil
    end

    it "includes command when present" do
      registry = registry_from_yaml(<<-EOYAML)
      rubocop:
        channels:
          stable: foo
          example: bar
        command:
        - echo
        - true
      EOYAML

      engine = double(name: "rubocop", channel: "example")
      engine_details = registry.fetch_engine_details(engine)

      expect(engine_details.image).to eq("bar")
      expect(engine_details.command).to eq(["echo", true])
    end

    it "raises for unknown engines" do
      registry = registry_from_yaml(<<-EOYAML)
      rubocop:
        channels:
          stable: foo
          example: bar
      EOYAML

      engine = double(name: "nope", channel: "beta")
      expect { registry.fetch_engine_details(engine) }.to raise_error(
        described_class::EngineDetailsNotFoundError,
        /details not found for nope/,
      )
    end

    it "raises for unknown channels" do
      registry = registry_from_yaml(<<-EOYAML)
      rubocop:
        channels:
          stable: foo
          example: bar
      EOYAML

      engine = double(name: "rubocop", channel: "nope")
      expect { registry.fetch_engine_details(engine) }.to raise_error(
        described_class::EngineDetailsNotFoundError,
        /details not found for rubocop:nope,.*\["stable", "example"\]/,
      )
    end

    it "makes up an engine in development mode" do
      registry = registry_from_yaml(<<-EOYAML)
      rubocop:
        channels:
          stable: foo
          example: bar
      EOYAML

      engine = double(name: "madeup")
      engine_details = registry.fetch_engine_details(engine, development: true)

      expect(engine_details.image).to eq "codeclimate/codeclimate-madeup"
    end
  end

  def registry_from_yaml(yaml)
    Tempfile.open("") do |tmp|
      tmp.puts(yaml)
      tmp.rewind
      described_class.new(tmp.path)
    end
  end
end
