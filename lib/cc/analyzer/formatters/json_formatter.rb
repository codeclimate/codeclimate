module CC
  module Analyzer
    module Formatters
      class JSONFormatter < Formatter
        def initialize(filesystem)
          @filesystem = filesystem
          @has_begun = false
        end

        def started
          print "["
        end

        def finished
          print "]\n"
        end

        def write(data)
          document = JSON.parse(data)
          document["engine_name"] = current_engine.name

          if @has_begun
            print ",\n"
          end

          print document.to_json
          @has_begun = true
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
