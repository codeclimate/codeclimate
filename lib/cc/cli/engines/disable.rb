require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Disable < Command
        include CC::Analyzer

        CODECLIMATE_YAML = ".codeclimate.yml".freeze

        def run
          if !filesystem.exist?(CODECLIMATE_YAML)
            say "No .codeclimate.yml file found. Run 'codeclimate init' to generate a config file."
          elsif !engine_exists?
            say "Engine not found. Run 'codeclimate engines:list for a list of valid engines."
          elsif !engine_present_in_yaml?
            say "Engine not found in .codeclimate.yml."
          else
            disable_engine
            update_yaml
            say "Engine removed from .codeclimate.yml."
          end
        end

        private

        def engine_name
          @engine_name ||= @args.first
        end

        def disable_engine
          parsed_yaml.disable_engine(engine_name)
        end

        def update_yaml
          File.open(filesystem.path_for(CODECLIMATE_YAML), "w") do |f|
            f.write(parsed_yaml.to_yaml)
          end
        end

        def parsed_yaml
          @parsed_yaml ||= CC::Analyzer::Config.new(yaml_content)
        end

        def yaml_content
          filesystem.read_path(CODECLIMATE_YAML).freeze
        end

        def engine_exists?
          engines_registry_list.keys.include?(engine_name)
        end

        def engine_present_in_yaml?
          parsed_yaml.engine_present?(engine_name)
        end

        def engines_registry_list
          @engines_registry_list ||= CC::Analyzer::EngineRegistry.new.list
        end

        def filesystem
          @filesystem ||= Filesystem.new(ENV['FILESYSTEM_DIR'])
        end
      end
    end
  end
end
