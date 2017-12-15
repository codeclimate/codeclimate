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

    describe "#glob?" do
      it "is not a glob when no glob chars are present in the pattern" do
        exclusion = Exclusion.new("foo")

        expect(exclusion).to_not be_glob
      end

      %w[* ?].each do |glob_char|
        it "is a glob when #{glob_char} is present in the pattern" do
          exclusion = Exclusion.new("foo#{glob_char}")

          expect(exclusion).to be_glob
        end
      end
    end
  end
end
