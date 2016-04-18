require "spec_helper"

module CC::Analyzer
  describe IssueLocationFormatValidation do
    describe "#valid?" do
      it "returns true if reported with lines" do
        expect(IssueLocationFormatValidation.new("location" => {
          "path" => "foo.rb",
          "lines" => {
            "begin" => 1,
            "end" => 2
          }
        })).to be_valid
      end

      it "returns true if reported with positions" do
        expect(IssueLocationFormatValidation.new("location" => {
          "path" => "foo.rb",
          "positions" => {
            "begin" => {
              "line" => 1,
              "column" => 1,
            },
            "end" => {
              "line" => 1,
              "column" => 9,
            }
          }
        })).to be_valid
      end

      it "returns true if reported with offsets" do
        expect(IssueLocationFormatValidation.new("location" => {
          "path" => "foo.rb",
          "positions" => {
            "begin" => {
              "offset" => 0,
            },
            "end" => {
              "offset" => 8,
            }
          }
        })).to be_valid
      end

      it "returns false if the position is badly formed" do
        expect(IssueLocationFormatValidation.new("location" => {
          "path" => "foo.rb",
          "positions" => "everywhere",
        })).not_to be_valid
      end

      it "returns false if the lines are badly formed" do
        expect(IssueLocationFormatValidation.new("location" => {
          "path" => "foo.rb",
          "positions" => {
            "lines" => "all of them"
          }
        })).not_to be_valid
      end
    end
  end
end
