require "cc/analyzer"

module CC
  module CLI
    module Engines
      class EngineCommand < Command
        include CC::Analyzer

        private

        def engine_name
          @engine_name ||= @args.first
        end

        def parsed_yaml
          @parsed_yaml ||= CC::Analyzer::Config.new(yaml_content)
        end

        def yaml_content
          filesystem.read_path(CODECLIMATE_YAML).freeze
        end

        def update_yaml
          filesystem.write_path(CODECLIMATE_YAML, parsed_yaml.to_yaml)
        end

        def engine_present_in_yaml?
          parsed_yaml.engine_present?(engine_name)
        end

        def engine_enabled?
          parsed_yaml.engine_enabled?(engine_name)
        end

        def engine_exists?
          engines_registry_list.keys.include?(engine_name)
        end

        def engines_registry_list
          @engines_registry_list ||= CC::Analyzer::EngineRegistry.new.list
        end
      end
    end
  end
end
