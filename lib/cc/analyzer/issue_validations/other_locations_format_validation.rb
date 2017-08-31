module CC
  module Analyzer
    module IssueValidations
      class OtherLocationsFormatValidation < Validation
        CHECKS = [
          LocationFormatValidation,
          PathExistenceValidation,
          PathPresenceValidation,
          RelativePathValidation,
        ].freeze

        def initialize(object)
          super
          @other_location_valid = {}
        end

        def valid?
          if object["other_locations"]
            object["other_locations"].is_a?(Array) &&
              object["other_locations"].all?(&method(:other_location_valid?))
          else
            true
          end
        end

        def message
          "Other locations are not formatted correctly"
        end

        private

        def other_location_valid?(location)
          path = location && location["path"]
          @other_location_valid[path] ||= CHECKS.all? do |klass|
            klass.new("location" => location).valid?
          end
        end
      end
    end
  end
end
