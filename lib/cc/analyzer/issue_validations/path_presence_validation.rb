module CC
  module Analyzer
    module IssueValidations
      class PathPresenceValidation < Validation
        def valid?
          path.present?
        end

        def message
          "Path must be present"
        end
      end
    end
  end
end
