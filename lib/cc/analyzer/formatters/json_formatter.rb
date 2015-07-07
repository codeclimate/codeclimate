module CC
  module Analyzer
    module Formatters
      class JSONFormatter < Formatter

        def engine_running(engine)
          @active_engine = engine
          yield
          @active_engine = nil
        end

        def started
          puts "[ "
        end

        def finished
          puts "\b\b ]"
        end

        def write(data)
          return unless data.present?

          document = JSON.parse(data)
          document["engine_name"] = @active_engine.name
          puts document.to_json + ","
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
