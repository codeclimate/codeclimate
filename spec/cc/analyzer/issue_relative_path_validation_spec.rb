require "spec_helper"

module CC::Analyzer
  describe IssueRelativePathValidation do
    describe "#valid?" do
      it "returns true if path is relative to the project directory" do
        expect(IssueRelativePathValidation.new("location" => {
          "path" => "spec/fixtures/source.rb"
        })).to be_valid
      end

      it "returns false if path is absolute" do
        expect(IssueRelativePathValidation.new("location" => {
          "path" => "#{MountedPath.code.container_path}/spec/fixtures/source.rb"
        })).not_to be_valid
      end

      it "returns false if relative path moves up directories" do
        expect(IssueRelativePathValidation.new("location" => {
          "path" => "../../foo.rb"
        })).not_to be_valid

        expect(IssueRelativePathValidation.new("location" => {
          "path" => "foo/../../../../bar"
        })).not_to be_valid
      end
    end
  end
end
