require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Disable < EngineCommand
        def run
          require_codeclimate_yml

          if !valid_engine?
            say "Engine not found. Run 'codeclimate engines:list' for a list of valid engines."
          elsif !engine_present?
            say "Engine not found in .codeclimate.yml."
          elsif !engine_enabled?
            say "Engine already disabled."
          else
            disable_engine
            say "Engine disabled."
          end
        end

        private

        def disable_engine
          config.engines[engine_name] ||= {}
          config.engines[engine_name].enabled = false

          write_config
        end
      end
    end
  end
end
