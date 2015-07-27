require "cc/analyzer"

module CC
  module CLI
    module Engines
      class EngineCommand < Command
        private

        def engine_name
          @engine_name ||= @args.first
        end

        def engine_present?
          config.engines.key?(engine_name)
        end

        def engine_enabled?
          engine_present? &&
            config.engines[engine_name].enabled?
        end

        def config
          @config ||= CC::Yaml.parse(filesystem.read_path(CODECLIMATE_YAML))
        end

        def write_config
          filesystem.write_path(CODECLIMATE_YAML, config.as_json.to_yaml)
        end

        def valid_engine?(name = engine_name)
          registry.list.keys.include?(name)
        end

        def registry
          @registry ||= CC::Analyzer::EngineRegistry.new
        end
      end
    end
  end
end
