module CC
  module Analyzer
    class Issue
      module Validations
        class PathPresenceValidation < Validation
          def valid?
            path.present?
          end

          def message
            "Path must be present"
          end

          private

          def path
            object.fetch("location", {})["path"]
          end
        end
      end
    end
  end
end
