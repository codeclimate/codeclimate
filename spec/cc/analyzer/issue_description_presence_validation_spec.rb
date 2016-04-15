require "spec_helper"

module CC::Analyzer
  describe IssueDescriptionPresenceValidation do
    describe "#valid?" do
      it "returns true" do
        expect(IssueDescriptionPresenceValidation.new("description" => "foo")).to be_valid
      end

      it "returns false" do
        expect(IssueDescriptionPresenceValidation.new({})).not_to be_valid
        expect(IssueDescriptionPresenceValidation.new({"description" => ""})).not_to be_valid
      end
    end
  end
end
