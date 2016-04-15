require "spec_helper"

module CC::Analyzer
  describe IssueCheckNamePresenceValidation do
    describe "#valid?" do
      it "returns true" do
        expect(IssueCheckNamePresenceValidation.new("check_name" => "foo")).to be_valid
      end

      it "returns false" do
        expect(IssueCheckNamePresenceValidation.new({})).not_to be_valid
      end
    end
  end
end
