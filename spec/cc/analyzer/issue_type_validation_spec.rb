require "spec_helper"

module CC::Analyzer
  describe IssueTypeValidation do
    describe "#valid?" do
      it "returns true" do
        expect(IssueTypeValidation.new("type" => "issue")).to be_valid
      end

      it "returns false" do
        expect(IssueTypeValidation.new("type" => "")).not_to be_valid
      end
    end
  end
end
