module CC
  module Analyzer
    module Formatters
      class JSONFormatter < Formatter
        def write(data)
          puts JSON.parse(data).to_json if data.present?
        end

        def failed(output)
          $stderr.puts "\nAnalysis failed with the following output:"
          $stderr.puts output
          exit 1
        end
      end
    end
  end
end
