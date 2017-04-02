module CC
  module Analyzer
    module Formatters
      class JSONFormatter < Formatter
        def initialize(filesystem)
          @filesystem = filesystem
          @emitted = false
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

          if @emitted
            print ",\n"
          end

          print document.to_json
          @emitted = true
        end

        def errored(output)
          $stderr.puts "\nAnalysis errored with the following output:"
          $stderr.puts output
          exit 1
        end

        def empty?
          @emitted
        end
      end
    end
  end
end
