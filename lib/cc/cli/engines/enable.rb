require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Enable < EngineCommand
        ARGUMENT_LIST = "<engine_name>".freeze
        SHORT_HELP = "Enable an engine in your codeclimate.yml.".freeze
        HELP = "#{SHORT_HELP}\n" \
          "\n"\
          "    <engine_name>    Engine to enable in your codeclimate.yml".freeze

        def run
          require_codeclimate_yml

          if !engine_exists?
            say "Engine not found. Run 'codeclimate engines:list' for a list of valid engines."
          elsif engine_enabled?
            say "Engine already enabled."
            pull_docker_images
          else
            enable_engine
            update_yaml
            say "Engine added to .codeclimate.yml."
            pull_docker_images
          end
        end

        private

        def pull_docker_images
          Engines::Install.new.run
        end

        def enable_engine
          parsed_yaml.enable_engine(engine_name)
        end
      end
    end
  end
end
