require "spec_helper"

module CC::Analyzer::IssueValidations
  describe PathPresenceValidation do
    describe "#valid?" do
      it "returns true" do
        expect(PathPresenceValidation.new("location" => { "path" => "foo" })).to be_valid
      end

      it "returns false" do
        expect(PathPresenceValidation.new({})).not_to be_valid
      end
    end
  end
end
