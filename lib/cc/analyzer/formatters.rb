module CC
  module Analyzer
    module Formatters
      autoload :Formatter,  "cc/analyzer/formatters/formatter"
      autoload :JSONFormatter, "cc/analyzer/formatters/json_formatter"
      autoload :PlainTextFormatter,  "cc/analyzer/formatters/plain_text_formatter"
      autoload :RawEngineDataFormatter, "cc/analyzer/formatters/raw_engine_data_formatter"
      autoload :Spinner, "cc/analyzer/formatters/spinner"

      FORMATTERS = {
        json: JSONFormatter,
        text: PlainTextFormatter,
        raw: RawEngineDataFormatter,
      }.freeze

      def self.resolve(name)
        FORMATTERS[name.to_sym] or raise InvalidFormatterError, "'#{name}' is not a valid formatter. Valid options are: #{FORMATTERS.keys.join(", ")}"
      end
    end
  end
end
