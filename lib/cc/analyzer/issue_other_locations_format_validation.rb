module CC
  module Analyzer
    class IssueOtherLocationsFormatValidation < Validation
      CHECKS = [
        IssueLocationFormatValidation,
        IssuePathExistenceValidation,
        IssuePathPresenceValidation,
        IssueRelativePathValidation,
      ].freeze

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
        CHECKS.all? do |klass|
          klass.new("location" => location).valid?
        end
      end
    end
  end
end
