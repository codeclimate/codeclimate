module CC
  module Analyzer
    module Formatters
      class JSONFormatter < Formatter
        def write(data)
          puts JSON.parse(data).to_json if data.present?
        end
      end
    end
  end
end
