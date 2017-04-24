require "spec_helper"

module CC::Analyzer::IssueValidations
  describe OtherLocationsFormatValidation do
    describe "#valid?" do
      it "returns true if the other locations are all valid" do
        within_temp_dir do
          make_file("foo.rb")

          locations = [
            {
              "path" => "foo.rb",
              "lines" => {
                "begin" => 1,
                "end" => 2,
              }
            },
            {
              "path" => "foo.rb",
              "positions" => {
                "begin" => {
                  "offset" => 0,
                },
                "end" => {
                  "offset" => 8,
                }
              },
            },
          ]

          expect(OtherLocationsFormatValidation.new("other_locations" => locations)).to be_valid
        end
      end

      it "returns false if the other locations are not valid" do
        within_temp_dir do
          make_file("foo.rb")

          locations = [
            {
              "path" => "foo.rb",
              "test" => 100
            },
          ]

          expect(OtherLocationsFormatValidation.new("other_locations" => locations)).not_to be_valid
        end
      end
    end
  end
end
