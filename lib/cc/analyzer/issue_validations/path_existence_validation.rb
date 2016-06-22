module CC
  module Analyzer
    module IssueValidations
      class PathExistenceValidation < Validation
        def valid?
          File.exist?(path)
        end

        def message
          "File does not exist: '#{path}'"
        end

        private

        def path
          object.fetch("location", {}).fetch("path", "")
        end
      end
    end
  end
end
