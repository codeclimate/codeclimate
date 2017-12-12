require "spec_helper"

module CC::Analyzer
  describe IssueValidations do
    describe ".validations" do
      it "gets the validation classes" do
        expected = [
          IssueValidations::CategoryValidation,
          IssueValidations::CheckNamePresenceValidation,
          IssueValidations::ContentValidation,
          IssueValidations::DescriptionPresenceValidation,
          IssueValidations::LocationFormatValidation,
          IssueValidations::OtherLocationsFormatValidation,
          IssueValidations::PathExistenceValidation,
          IssueValidations::PathIsFileValidation,
          IssueValidations::PathPresenceValidation,
          IssueValidations::RelativePathValidation,
          IssueValidations::RemediationPointsValidation,
          IssueValidations::SeverityValidation,
          IssueValidations::TypeValidation,
        ]

        expect(IssueValidations.validations).to eq(expected)
      end
    end
  end
end
