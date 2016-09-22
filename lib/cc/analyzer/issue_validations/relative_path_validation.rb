require "pathname"

module CC
  module Analyzer
    module IssueValidations
      class RelativePathValidation < Validation
        def valid?
          path &&
            !path.start_with?("/") &&
            relative_to?(MountedPath.code.container_path)
        end

        def message
          "Path must be relative to the project directory"
        end

        private

        def relative_to?(directory)
          expanded_base = Pathname.new(directory).expand_path.to_s
          expanded_path = Pathname.new(path).expand_path.to_s

          expanded_path.start_with?(expanded_base)
        end
      end
    end
  end
end
