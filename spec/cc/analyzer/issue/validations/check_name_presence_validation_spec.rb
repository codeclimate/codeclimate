require "spec_helper"

module CC::Analyzer::Issue::Validations
  describe CheckNamePresenceValidation do
    describe "#valid?" do
      it "returns true" do
        CheckNamePresenceValidation.new("check_name" => "foo").
          valid?.must_equal(true)
      end

      it "returns false" do
        CheckNamePresenceValidation.new({}).valid?.must_equal(false)
      end
    end
  end
end
