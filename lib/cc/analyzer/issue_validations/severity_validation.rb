# frozen_string_literal: true

module CC
  module Analyzer
    module IssueValidations
      class SeverityValidation < Validation
        INFO = "info"
        MINOR = "minor"
        MAJOR = "major"
        CRITICAL = "critical"
        BLOCKER = "blocker"

        DEPRECATED_SEVERITIES = [
          NORMAL = "normal",
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
