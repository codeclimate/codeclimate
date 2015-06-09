module CC
  module CLI
    module Engines
      class List < Command
        def run
          say "Available engines:"
          engines.each do |name, attributes|
            say "- #{name}: #{attributes["description"]}"
          end
        end

        private

        def engines
          @engines ||= CC::Analyzer::EngineRegistry.new.list
        end
      end
    end
  end
end
