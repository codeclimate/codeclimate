require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Remove < EngineCommand
        def run
          require_codeclimate_yml

          if !valid_engine?
            say "Engine not found. Run 'codeclimate engines:list' for a list of valid engines."
          elsif !engine_present?
            say "Engine not found in .codeclimate.yml."
          else
            remove_engine
            say "Engine removed from .codeclimate.yml."
          end
        end

        private

        def remove_engine
          config.engines.delete(engine_name)
          write_config
        end
      end
    end
  end
end
