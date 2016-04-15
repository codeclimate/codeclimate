module CC
  module Analyzer
    class IssueCategoryValidation < Validation
      CATEGORIES = [
        "Bug Risk",
        "Clarity",
        "Compatibility",
        "Complexity",
        "Duplication",
        "Performance",
        "Security",
        "Style",
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
