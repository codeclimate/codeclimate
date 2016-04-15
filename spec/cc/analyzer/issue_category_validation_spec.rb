require "spec_helper"

module CC::Analyzer
  describe IssueCategoryValidation do
    describe "#valid?" do
      it "returns true" do
        expect(IssueCategoryValidation.new("categories" => ["Style"])).to be_valid
      end

      it "returns false" do
        expect(IssueCategoryValidation.new("categories" => ["Bag Possibility"])).not_to be_valid
        expect(IssueCategoryValidation.new("categories" => ["Style", "Bag Possibility"])).not_to be_valid
        expect(IssueCategoryValidation.new("categories" => [])).not_to be_valid
        expect(IssueCategoryValidation.new("categories" => nil)).not_to be_valid
      end
    end
  end
end
