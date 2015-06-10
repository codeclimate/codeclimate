require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Enable < Command
        include CC::Analyzer

        CODECLIMATE_YAML = ".codeclimate.yml".freeze

        def run
          if !filesystem.exist?(CODECLIMATE_YAML)
            say "No .codeclimate.yml file found. Run 'codeclimate init' to generate a config file."
          elsif !engine_exists?
            say "Engine not found. Run 'codeclimate engines:list for a list of valid engines."
          elsif engine_already_enabled?
            say "Engine already enabled."
          else
            enable_engine
            update_yaml
            say "Engine added."
          end
        end

        private

        def engine_name
          @args.first
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

        def engine_already_enabled?
          parsed_yaml.engine_enabled?(engine_name)
        end

        def enable_engine
          parsed_yaml.enable_engine(engine_name)
        end

        def engine_exists?
          engines.include?(engine_name)
        end

        def engines
          @engines ||= CC::Analyzer::EngineRegistry.new.list
        end

        def filesystem
          @filesystem ||= Filesystem.new("/code")
        end
      end
    end
  end
end
