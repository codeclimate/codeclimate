module CC
  module Analyzer
    module Formatters
      class JSONFormatter < Formatter
        def write(data)
          puts JSON.parse(data).to_json
        end
      end
    end
  end
end
