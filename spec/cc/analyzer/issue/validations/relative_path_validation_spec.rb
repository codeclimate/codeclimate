require "spec_helper"

module CC::Analyzer::Issue::Validations
  describe RelativePathValidation do
    describe "#valid?" do
      it "returns true" do
        RelativePathValidation.new("location" => { "path" => "foo.rb" }).
          valid?.must_equal(true)
      end

      it "returns false" do
        RelativePathValidation.new("location" => { "path" => "/foo.rb" }).
          valid?.must_equal(false)
      end
    end
  end
end
