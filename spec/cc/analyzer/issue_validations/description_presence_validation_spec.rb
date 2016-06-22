require "spec_helper"

module CC::Analyzer::IssueValidations
  describe DescriptionPresenceValidation do
    describe "#valid?" do
      it "returns true" do
        expect(DescriptionPresenceValidation.new("description" => "foo")).to be_valid
      end

      it "returns false" do
        expect(DescriptionPresenceValidation.new({})).not_to be_valid
        expect(DescriptionPresenceValidation.new({"description" => ""})).not_to be_valid
      end
    end
  end
end
