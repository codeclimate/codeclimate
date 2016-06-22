module CC
  module Analyzer
    module IssueValidations
      class CheckNamePresenceValidation < Validation
        def valid?
          object["check_name"].present?
        end

        def message
          "Check name must be present"
        end
      end
    end
  end
end
