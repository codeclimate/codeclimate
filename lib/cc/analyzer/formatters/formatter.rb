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
          @current_engine = engine
          yield
        ensure
          @current_engine = nil
        end

        def finished
        end

        def failed(output)
        end

        InvalidFormatterError = Class.new(StandardError)

        private

        attr_reader :current_engine
      end
    end
  end
end
