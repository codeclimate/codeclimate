require "spec_helper"

module CC::Analyzer::Issue::Validations
  describe PathPresenceValidation do
    describe "#valid?" do
      it "returns true" do
        PathPresenceValidation.new("location" => { "path" => "foo" }).
          valid?.must_equal(true)
      end

      it "returns false" do
        PathPresenceValidation.new({}).valid?.must_equal(false)
      end
    end
  end
end
