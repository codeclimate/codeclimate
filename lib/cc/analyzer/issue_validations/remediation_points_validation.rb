module CC
  module Analyzer
    module IssueValidations
      class RemediationPointsValidation < Validation
        def valid?
          remediation_points.nil? || positive_integer?(remediation_points)
        end

        def message
          "Remediation points must be a non-negative integer"
        end

        private

        def remediation_points
          @remediation_points ||= object["remediation_points"]
        end

        def positive_integer?(points)
          points.is_a?(Integer) && points >= 0
        end
      end
    end
  end
end
