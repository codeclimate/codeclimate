module CC
  module Analyzer
    module Formatters
      autoload :Formatter,  "cc/analyzer/formatters/formatter"
      autoload :JSONFormatter, "cc/analyzer/formatters/json_formatter"
      autoload :PlainTextFormatter,  "cc/analyzer/formatters/plain_text_formatter"
    end
  end
end
