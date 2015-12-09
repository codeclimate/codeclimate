module CC
  module Analyzer
    class Issue
      module Validations
        autoload :Validation, "cc/analyzer/issue/validations/validation"
        autoload :CheckNamePresenceValidation, "cc/analyzer/issue/validations/check_name_presence_validation"
        autoload :PathPresenceValidation, "cc/analyzer/issue/validations/path_presence_validation"
        autoload :RelativePathValidation, "cc/analyzer/issue/validations/relative_path_validation"
        autoload :TypeValidation, "cc/analyzer/issue/validations/type_validation"
      end
    end
  end
end
