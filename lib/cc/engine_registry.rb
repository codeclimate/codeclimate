module CC
  class EngineRegistry
    include Enumerable

    DEFAULT_MEMORY_LIMIT = 1_024_000_000
    DEFAULT_COMMAND = nil
    DEFAULT_MANIFEST_PATH = File.expand_path("../../../config/engines.yml", __FILE__)

    EngineDetails = Struct.new(:image, :command, :description, :memory, :source_library, :channel_versions, :plugin)
    EngineDetailsNotFoundError = Class.new(StandardError)

    def initialize(path = DEFAULT_MANIFEST_PATH, prefix = nil)
      @yaml = YAML.safe_load(File.read(path))
      @prefix = prefix || ENV["CODECLIMATE_PREFIX"] || ""
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
          memory_limit(metadata["minimum_memory_limit"]),
          metadata.fetch("source-library", {}),
          metadata.fetch("channel-versions", {}),
          metadata.fetch("plugin", {}),
        )
      end
    rescue KeyError
      raise EngineDetailsNotFoundError, not_found_message(engine, channels)
    end

    private

    attr_reader :yaml, :prefix

    def memory_limit(minimum_memory_limit)
      [
        minimum_memory_limit.to_i,
        default_memory_limit.to_i,
      ].max
    end

    def default_memory_limit
      ENV["ENGINE_MEMORY_LIMIT_BYTES"] || DEFAULT_MEMORY_LIMIT
    end

    def not_found_message(engine, available_channels)
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
