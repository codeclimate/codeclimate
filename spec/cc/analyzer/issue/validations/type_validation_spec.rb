require "spec_helper"

module CC::Analyzer::Issue::Validations
  describe TypeValidation do
    describe "#valid?" do
      it "returns true" do
        TypeValidation.new("type" => "issue").valid?.must_equal(true)
      end

      it "returns false" do
        TypeValidation.new("type" => "").valid?.must_equal(false)
      end
    end
  end
end
