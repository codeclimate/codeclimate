module CC
  module Analyzer
    module IssueValidations
      class DescriptionPresenceValidation < Validation
        def valid?
          object["description"].present?
        end

        def message
          "Description must be present"
        end
      end
    end
  end
end
