module CC
  module Analyzer
    module IssueValidations
      class TypeValidation < Validation
        def valid?
          type && type.casecmp("issue").zero?
        end

        def message
          "Type must be 'issue' but was '#{type}'"
        end

        private

        def type
          object["type"]
        end
      end
    end
  end
end
