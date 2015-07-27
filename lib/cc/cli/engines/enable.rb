require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Enable < EngineCommand
        def run
          require_codeclimate_yml

          if !valid_engine?
            say "Engine not found. Run 'codeclimate engines:list' for a list of valid engines."
          elsif engine_enabled?
            say "Engine already enabled."
            pull_docker_images
          else
            enable_engine
            say "Engine added to .codeclimate.yml."
            pull_docker_images
          end
        end

        private

        def pull_docker_images
          Engines::Install.new.run
        end

        def enable_engine
          config.engines[engine_name] ||= {}
          config.engines[engine_name].enabled = true

          write_config
        end
      end
    end
  end
end
