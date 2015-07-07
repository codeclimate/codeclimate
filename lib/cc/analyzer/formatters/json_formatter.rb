module CC
  module Analyzer
    module Formatters
      class JSONFormatter < Formatter

        def initialize
          @has_begun = false
        end

        def engine_running(engine)
          @active_engine = engine
          yield
          @active_engine = nil
        end

        def started
          print "[ "
        end

        def finished
          print " ]\n"
        end

        def write(data)
          return unless data.present?

          document = JSON.parse(data)
          document["engine_name"] = @active_engine.name

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
