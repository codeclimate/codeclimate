module CC
  module Analyzer
    class Issue
      module Validations
        class TypeValidation < Validation
          def valid?
            type && type.downcase == "issue"
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
end
