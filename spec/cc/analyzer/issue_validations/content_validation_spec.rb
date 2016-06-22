require "spec_helper"

module CC::Analyzer::IssueValidations
  describe ContentValidation do
    describe "#valid?" do
      it "is valid without any content" do
        expect(ContentValidation.new({})).to be_valid
      end

      it "is valid with content with body" do
        expect(ContentValidation.new("content" => { "body" => "hi"})).to be_valid
      end

      it "is not valid with content as string" do
        expect(ContentValidation.new("content" => "hi")).not_to be_valid
      end

      it "is not valid with content as nil" do
        expect(ContentValidation.new("content" => nil)).not_to be_valid
      end

      it "is not valid with content without body" do
        expect(ContentValidation.new("content" => {})).not_to be_valid
      end

      it "is not valid with content with nil body" do
        expect(ContentValidation.new("content" => { "body" => nil })).not_to be_valid
      end
    end
  end
end
