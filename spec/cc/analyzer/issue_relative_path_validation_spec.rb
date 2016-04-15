require "spec_helper"

module CC::Analyzer
  describe IssueRelativePathValidation do
    describe "#valid?" do
      it "returns true" do
        expect(IssueRelativePathValidation.new("location" => { "path" => "foo.rb" })).to be_valid
      end

      it "returns false" do
        expect(IssueRelativePathValidation.new("location" => { "path" => "/foo.rb" })).not_to be_valid
      end
    end
  end
end
