require "spec_helper"

module CC::Analyzer
  describe IssuePathPresenceValidation do
    describe "#valid?" do
      it "returns true" do
        expect(IssuePathPresenceValidation.new("location" => { "path" => "foo" })).to be_valid
      end

      it "returns false" do
        expect(IssuePathPresenceValidation.new({})).not_to be_valid
      end
    end
  end
end
