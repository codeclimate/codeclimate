require "safe_yaml/load"

module CC
  class EngineRegistry
    DEFAULT_COMMAND = nil
    DEFAULT_MANIFEST_PATH = File.expand_path("../../../config/engines.yml", __FILE__)

    EngineDetails = Struct.new(:image, :command)
    EngineDetailsNotFoundError = Class.new(StandardError)

    def initialize(path = DEFAULT_MANIFEST_PATH, prefix = "")
      @yaml = SafeYAML.load_file(path)
      @prefix = prefix
    end

    def fetch_engine_details(engine, development: false)
      if development
        EngineDetails.new("codeclimate/codeclimate-#{engine.name}", nil)
      else
        metadata = yaml.fetch(engine.name)
        channels = metadata.fetch("channels")

        EngineDetails.new(
          [prefix, channels.fetch(engine.channel)].join,
          metadata.fetch("command", DEFAULT_COMMAND),
        )
      end
    rescue KeyError => ex
      raise EngineDetailsNotFoundError, not_found_message(ex, engine, channels)
    end

    private

    attr_reader :yaml, :prefix

    def not_found_message(ex, engine, available_channels)
      "Engine details not found" \
        " for #{engine.name}:#{engine.channel}," \
        " available channels: #{available_channels.inspect}"
    end
  end
end
