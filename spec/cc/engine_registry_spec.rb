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
        /No engine named nope found/,
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
        /Channel nope not found for rubocop,.*\["stable", "example"\]/,
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

    describe "memory limits" do
      let(:registry) {
        registry_from_yaml(<<-EOYAML)
          sonar-java:
            channels:
              stable: foo
            minimum_memory_limit: 2_048_000_000
        EOYAML
      }
      let(:engine) { double(name: "sonar-java", channel: "stable") }

      it "uses at least the minimum set by the engine" do
        ENV["ENGINE_MEMORY_LIMIT_BYTES"] = "1_500_000_000"
        engine_details = registry.fetch_engine_details(engine)

        expect(engine_details.memory).to eq 2_048_000_000
      end

      it "uses ENGINE_MEMORY_LIMIT_BYTES" do
        ENV["ENGINE_MEMORY_LIMIT_BYTES"] = "4_000_000_000"
        engine_details = registry.fetch_engine_details(engine)

        expect(engine_details.memory).to eq 4_000_000_000
      end
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
