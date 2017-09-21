module CC
  class EngineRegistry
    DEFAULT_COMMAND = nil
    DEFAULT_MANIFEST_PATH = File.expand_path("../../../config/engines.yml", __FILE__)

    EngineDetails = Struct.new(:image, :command, :auto_enable_paths)
    EngineDetailsNotFoundError = Class.new(StandardError)

    def initialize(path = DEFAULT_MANIFEST_PATH, prefix = "")
      @yaml = YAML.safe_load(File.read(path))
      @prefix = prefix
    end

    def fetch_engine_details(engine, development: false)
      if development
        EngineDetails.new("codeclimate/codeclimate-#{engine.name}", nil, [])
      else
        metadata = yaml.fetch(engine.name)
        channels = metadata.fetch("channels")

        EngineDetails.new(
          [prefix, channels.fetch(engine.channel)].join,
          metadata.fetch("command", DEFAULT_COMMAND),
          metadata.fetch("auto_enable_paths", []),
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
        "Engine details not found" \
          " for #{engine.name}:#{engine.channel}," \
          " available channels: #{available_channels.keys.inspect}"
      else
        # Unknown engine
        "Engine details not found for #{engine.name}"
      end
    end
  end
end
