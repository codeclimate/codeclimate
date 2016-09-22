module CC
  module Analyzer
    module IssueValidations
      class ContentValidation < Validation
        def valid?
          !has_content? || (content.is_a?(Hash) && content["body"].is_a?(String))
        end

        def message
          "Content must be a hash containing a 'body' key with string contents"
        end

        private

        def has_content?
          object.key?("content")
        end
      end
    end
  end
end
