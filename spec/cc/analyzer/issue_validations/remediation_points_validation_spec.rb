require "spec_helper"

module CC::Analyzer::IssueValidations
  describe RemediationPointsValidation do
    describe "#valid?" do
      context "when points is missing" do
        it "is valid" do
          expect(RemediationPointsValidation.new({})).to be_valid
        end
      end

      context "when points is 0" do
        it "is valid" do
          expect(RemediationPointsValidation.new("remediation_points" => 0)).to be_valid
        end
      end

      context "when points is greater than 0" do
        it "is valid" do
          expect(RemediationPointsValidation.new("remediation_points" => 42)).to be_valid
        end
      end

      context "when points is less than 0" do
        it "is not valid" do
          expect(RemediationPointsValidation.new("remediation_points" => -42)).not_to be_valid
        end
      end

      context "when points is a float" do
        it "is not valid" do
          expect(RemediationPointsValidation.new("remediation_points" => 4.2)).not_to be_valid
        end
      end

      context "when points is a string" do
        it "is not valid" do
          expect(RemediationPointsValidation.new("remediation_points" => "foo")).not_to be_valid
        end
      end
    end

    describe "#message" do
      it "is a message" do
        expect(RemediationPointsValidation.new("remediation_points" => -42).message)
          .to match("Remediation points must be a non-negative integer")
      end
    end
  end
end
