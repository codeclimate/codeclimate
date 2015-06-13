module CC
  module CLI
    module Engines
      class List < EngineCommand
        def run
          say "Available engines:"
          engines_registry_list.each do |name, attributes|
            say "- #{name}: #{attributes["description"]}"
          end
        end
      end
    end
  end
end
