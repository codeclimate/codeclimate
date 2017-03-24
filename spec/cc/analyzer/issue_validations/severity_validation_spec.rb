require "spec_helper"

module CC::Analyzer::IssueValidations
  describe SeverityValidation do
    describe "#valid?" do
      let(:valid) { SeverityValidation::MINOR }
      let(:deprecated) { SeverityValidation::DEPRECATED_SEVERITIES.first }

      context "when severity present and valid" do
        it "returns true" do
          expect(SeverityValidation.new("severity" => valid)).to be_valid
        end
      end

      context "when severity is absent" do
        it "returns true" do
          expect(SeverityValidation.new("severity" => nil)).to be_valid
        end
      end

      context "when severity is valid but deprecated" do
        it "returns true" do
          expect(SeverityValidation.new("severity" => deprecated)).to be_valid
        end
      end

      context "when severity present and invalid" do
        it " returns false" do
          expect(SeverityValidation.new("severity" => "9000")).not_to be_valid
        end
      end
    end

    describe "#message" do
      it "returns a list of permitted severities" do
        expect(SeverityValidation.new("severity" => "9000").message)
          .to match("Permitted severities include")
      end
    end
  end
end
