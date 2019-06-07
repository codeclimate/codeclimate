module CC
  module Analyzer
    module IssueValidations
      class TypeValidation < Validation
        def valid?
          type&.casecmp("issue")&.zero?
        end

        def message
          "Type must be 'issue' but was '#{type}'"
        end
      end
    end
  end
end
