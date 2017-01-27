module CC
  module CLI
    module Engines
      class List < EngineCommand
        SHORT_HELP = "List all available engines".freeze

        def run
          say "Available engines:"
          engine_registry_list.sort_by { |name, _| name }.each do |name, attributes|
            say "- #{name}: #{attributes["description"]}"
          end
        end
      end
    end
  end
end
