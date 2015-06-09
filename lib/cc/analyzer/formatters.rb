module CC
  module Analyzer
    module Formatters
      autoload :Formatter,  "cc/analyzer/formatters/formatter"
      autoload :JSONFormatter, "cc/analyzer/formatters/json_formatter"
      autoload :PlainText,  "cc/analyzer/formatters/plain_text"
    end
  end
end
