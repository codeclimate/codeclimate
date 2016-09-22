module CC
  module Analyzer
    module IssueValidations
      class PathExistenceValidation < Validation
        def valid?
          path && File.exist?(path)
        end

        def message
          "File does not exist: '#{path}'"
        end
      end
    end
  end
end
