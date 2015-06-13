require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Enable < EngineCommand
        def run
          if !filesystem.exist?(CODECLIMATE_YAML)
            say "No .codeclimate.yml file found. Run 'codeclimate init' to generate a config file."
          elsif !engine_exists?
            say "Engine not found. Run 'codeclimate engines:list for a list of valid engines."
          elsif engine_enabled?
            say "Engine already enabled."
            pull_uninstalled_docker_images
          else
            enable_engine
            update_yaml
            say "Engine added to .codeclimate.yml."
            pull_uninstalled_docker_images
          end
        end

        private

        def pull_uninstalled_docker_images
          Engines::Install.new.run
        end

        def enable_engine
          parsed_yaml.enable_engine(engine_name)
        end
      end
    end
  end
end
