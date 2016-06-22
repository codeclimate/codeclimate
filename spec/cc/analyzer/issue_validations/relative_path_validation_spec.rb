require "spec_helper"

module CC::Analyzer::IssueValidations
  describe RelativePathValidation do
    describe "#valid?" do
      it "returns true if path is relative to the project directory" do
        expect(RelativePathValidation.new("location" => {
          "path" => "spec/fixtures/source.rb"
        })).to be_valid
      end

      it "returns false if path is absolute" do
        expect(RelativePathValidation.new("location" => {
          "path" => "#{CC::Analyzer::MountedPath.code.container_path}/spec/fixtures/source.rb"
        })).not_to be_valid
      end

      it "returns false if relative path moves up directories" do
        expect(RelativePathValidation.new("location" => {
          "path" => "../../foo.rb"
        })).not_to be_valid

        expect(RelativePathValidation.new("location" => {
          "path" => "foo/../../../../bar"
        })).not_to be_valid
      end
    end
  end
end
