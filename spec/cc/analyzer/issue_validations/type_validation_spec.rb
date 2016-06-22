require "spec_helper"

module CC::Analyzer::IssueValidations
  describe TypeValidation do
    describe "#valid?" do
      it "returns true" do
        expect(TypeValidation.new("type" => "issue")).to be_valid
      end

      it "returns false" do
        expect(TypeValidation.new("type" => "")).not_to be_valid
      end
    end
  end
end
