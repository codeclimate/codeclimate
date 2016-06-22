module CC
  module Analyzer
    module IssueValidations
      class PathIsFileValidation < Validation
        def valid?
          File.file?(path)
        end

        def message
          "Path is not a file: '#{path}'"
        end

        private

        def path
          object.fetch("location", {}).fetch("path", "")
        end
      end
    end
  end
end
