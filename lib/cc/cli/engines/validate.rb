require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Validate < EngineCommand
        def run
          if invalid_engines.any?
            warn
            true
          end
        end

        private

        def warn
          invalid_engines.each do |engine|
            puts colorize("WARNING: unknown engine <#{engine}>", :red)
          end
        end

        def invalid_engines
          @invalid_engines ||= engine_names.reject { |engine_name| engine_exists? engine_name }
        end

        def engine_names
          @engine_names ||= parsed_yaml.engine_names
        end

        def engine_exists?(engine_name)
          engines_registry_list.keys.include?(engine_name)
        end
      end
    end
  end
end
