require "spec_helper"

module CC::Analyzer
  describe IssuePathIsFileValidation do
    describe "#valid?" do
      it "returns true" do
        within_temp_dir do
          make_file("foo.rb")

          expect(IssuePathIsFileValidation.new("location" => { "path" => "foo.rb" })).to be_valid
        end
      end

      it "returns false" do
        within_temp_dir do
          Dir.mkdir("foo.rb")

          expect(IssuePathIsFileValidation.new("location" => { "path" => "foo.rb" })).not_to be_valid
        end
      end
    end
  end
end
