module CC
  module Analyzer
    module IssueValidations
      class PathIsFileValidation < Validation
        def valid?
          path && File.file?(path)
        end

        def message
          "Path is not a file: '#{path}'"
        end
      end
    end
  end
end
