require "spec_helper"

class CC::Workspace
  describe Exclusion do
    it "sets negated if pattern starts with !" do
      exclusion = Exclusion.new("!foo")
      expect(exclusion.negated?).to eq(true)

      exclusion = Exclusion.new("foo")
      expect(exclusion.negated?).to eq(false)
    end

    it "strips leading ! for expansion" do
      exclusion = Exclusion.new("!foo")
      expect(exclusion.expand).to eq(["foo"])
    end
  end
end
