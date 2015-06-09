module CC
  module Analyzer
    module Formatters
      class Formatter

        FORMATTERS = {
          json: JSONFormatter,
          text: PlainTextFormatter,
        }.freeze

        def self.resolve(name)
          FORMATTERS[name.to_sym].new or raise InvalidFormatterError, "'#{name}' is not a valid formatter. Valid options are: #{FORMATTERS.keys.join(", ")}"
        end

        def initialize(output = $stdout)
          @output = output
        end

        def write(data)
        end

        def started
        end

        def finished
        end

        InvalidFormatterError = Class.new(StandardError)
      end
    end
  end
end
