module CC
  module Analyzer
    module IssueValidations
      class SeverityValidation < Validation
        INFO = "info".freeze
        MINOR = "minor".freeze
        MAJOR = "major".freeze
        CRITICAL = "critical".freeze
        BLOCKER = "blocker".freeze

        DEPRECATED_SEVERITIES = [
          NORMAL = "normal".freeze,
        ].freeze

        VALID_SEVERITIES = ([
          INFO,
          MINOR,
          MAJOR,
          CRITICAL,
          BLOCKER,
        ] + DEPRECATED_SEVERITIES).freeze

        def valid?
          severity.nil? || VALID_SEVERITIES.include?(severity)
        end

        def message
          "Permitted severities include #{VALID_SEVERITIES.join(", ")}"
        end

        private

        def severity
          @severity ||= object["severity"]
        end
      end
    end
  end
end
