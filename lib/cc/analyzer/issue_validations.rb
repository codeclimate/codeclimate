module CC
  module Analyzer
    module IssueValidations
      autoload :CategoryValidation, "cc/analyzer/issue_validations/category_validation"
      autoload :CheckNamePresenceValidation, "cc/analyzer/issue_validations/check_name_presence_validation"
      autoload :ContentValidation, "cc/analyzer/issue_validations/content_validation"
      autoload :DescriptionPresenceValidation, "cc/analyzer/issue_validations/description_presence_validation"
      autoload :LocationFormatValidation, "cc/analyzer/issue_validations/location_format_validation"
      autoload :OtherLocationsFormatValidation, "cc/analyzer/issue_validations/other_locations_format_validation"
      autoload :PathExistenceValidation, "cc/analyzer/issue_validations/path_existence_validation"
      autoload :PathIsFileValidation, "cc/analyzer/issue_validations/path_is_file_validation"
      autoload :PathPresenceValidation, "cc/analyzer/issue_validations/path_presence_validation"
      autoload :RelativePathValidation, "cc/analyzer/issue_validations/relative_path_validation"
      autoload :RemediationPointsValidation, "cc/analyzer/issue_validations/remediation_points_validation"
      autoload :SeverityValidation, "cc/analyzer/issue_validations/severity_validation"
      autoload :TypeValidation, "cc/analyzer/issue_validations/type_validation"
      autoload :Validation, "cc/analyzer/issue_validations/validation"

      def self.validations
        constants.sort.map(&method(:const_get)).select do |klass|
          klass.is_a?(Class) && klass.superclass == Validation
        end
      end
    end
  end
end
