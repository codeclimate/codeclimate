module CC
  module Analyzer
    module Formatters
      class JSON < Formatter

        def file_analyzed(path, result)
          result.issues.each do |issue|
            @output.puts issue.as_json.to_json
          end
        end

      end
    end
  end
end
