require "spec_helper"

module CC::Analyzer::IssueValidations
  describe CheckNamePresenceValidation do
    describe "#valid?" do
      it "returns true" do
        expect(CheckNamePresenceValidation.new("check_name" => "foo")).to be_valid
      end

      it "returns false" do
        expect(CheckNamePresenceValidation.new({})).not_to be_valid
      end
    end
  end
end
