module CC
  class EngineRegistry
    include Enumerable

    DEFAULT_COMMAND = nil
    DEFAULT_MANIFEST_PATH = File.expand_path("../../../config/engines.yml", __FILE__)

    EngineDetails = Struct.new(:image, :command, :description, :memory)
    EngineDetailsNotFoundError = Class.new(StandardError)

    def initialize(path = DEFAULT_MANIFEST_PATH, prefix = "")
      @yaml = YAML.safe_load(File.read(path))
      @prefix = prefix
    end

    def each
      yaml.each do |name, metadata|
        engine = Config::Engine.new(
          name,
          channel: metadata.fetch("channels").keys.first,
        )
        engine_details = fetch_engine_details(engine)

        yield(engine, engine_details)
      end
    end

    def fetch_engine_details(engine, development: false)
      if development
        EngineDetails.new("codeclimate/codeclimate-#{engine.name}", nil, "")
      else
        metadata = yaml.fetch(engine.name)
        channels = metadata.fetch("channels")

        EngineDetails.new(
          [prefix, channels.fetch(engine.channel)].join,
          metadata.fetch("command", DEFAULT_COMMAND),
          metadata.fetch("description", "(No description available)"),
          metadata.fetch("memory", nil),
        )
      end
    rescue KeyError => ex
      raise EngineDetailsNotFoundError, not_found_message(ex, engine, channels)
    end

    private

    attr_reader :yaml, :prefix

    def not_found_message(ex, engine, available_channels)
      if available_channels
        # Known engine, unknown channel
        "Channel #{engine.channel} not found" \
          " for #{engine.name}," \
          " available channels: #{available_channels.keys.inspect}"
      else
        # Unknown engine
        "No engine named #{engine.name} found"
      end
    end
  end
end
