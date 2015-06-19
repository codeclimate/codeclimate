module CC
  module Analyzer
    module Formatters
      class Formatter
        def initialize(output = $stdout)
          @output = output
        end

        def write(data)
        end

        def started
        end

        def engine_running(engine)
          yield
        end

        def finished
        end

        def failed(output)
        end

        InvalidFormatterError = Class.new(StandardError)
      end
    end
  end
end
