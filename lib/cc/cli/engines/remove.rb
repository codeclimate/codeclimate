require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Remove < EngineCommand
        ARGUMENT_LIST = "<engine_name>".freeze
        SHORT_HELP = "Remove an engine from your codeclimate.yml.".freeze
        HELP = "#{SHORT_HELP} This command deletes the config rather than setting it to disabled.\n" \
          "\n"\
          "    <engine_name>    Engine to remove from your codeclimate.yml".freeze

        def run
          require_codeclimate_yml

          if !engine_exists?
            say "Engine not found. Run 'codeclimate engines:list' for a list of valid engines."
          elsif !engine_present_in_yaml?
            say "Engine not found in .codeclimate.yml."
          else
            remove_engine
            update_yaml
            say "Engine removed from .codeclimate.yml."
          end
        end

        private

        def remove_engine
          parsed_yaml.remove_engine(engine_name)
        end
      end
    end
  end
end
