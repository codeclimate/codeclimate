module CC
  module Analyzer
    module Formatters
      class Formatter

        def initialize(output = $stdout)
          @output = output
        end

        def started(engine_name, paths)
        end

        def file_analyzed(path, result)
        end

        def finished
        end

      end
    end
  end
end
