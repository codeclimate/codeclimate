require "spec_helper"

module CC::Analyzer::IssueValidations
  describe CategoryValidation do
    describe "#valid?" do
      it "returns true" do
        expect(CategoryValidation.new("categories" => ["Style"])).to be_valid
      end

      it "returns false" do
        expect(CategoryValidation.new("categories" => ["Bag Possibility"])).not_to be_valid
        expect(CategoryValidation.new("categories" => ["Style", "Bag Possibility"])).not_to be_valid
        expect(CategoryValidation.new("categories" => [])).not_to be_valid
        expect(CategoryValidation.new("categories" => nil)).not_to be_valid
      end
    end
  end
end
