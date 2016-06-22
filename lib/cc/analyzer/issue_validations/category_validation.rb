module CC
  module Analyzer
    module IssueValidations
      class CategoryValidation < Validation
        CATEGORIES = [
          "Bug Risk".freeze,
          "Clarity".freeze,
          "Compatibility".freeze,
          "Complexity".freeze,
          "Duplication".freeze,
          "Performance".freeze,
          "Security".freeze,
          "Style".freeze,
        ].freeze

        def valid?
          object["categories"].present? && no_invalid_categories?
        end

        def message
          "Category must be at least one of #{CATEGORIES.join(", ")}"
        end

        private

        def no_invalid_categories?
          (CATEGORIES | object["categories"]) == CATEGORIES
        end
      end
    end
  end
end
