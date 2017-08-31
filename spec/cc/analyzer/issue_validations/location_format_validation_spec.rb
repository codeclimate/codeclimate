require "spec_helper"

module CC::Analyzer::IssueValidations
  describe LocationFormatValidation do
    describe "#valid?" do
      it "returns true if reported with lines" do
        expect(LocationFormatValidation.new("location" => {
          "path" => "foo.rb",
          "lines" => {
            "begin" => 1,
            "end" => 2
          }
        })).to be_valid
      end

      it "returns true if reported with positions" do
        expect(LocationFormatValidation.new("location" => {
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
        expect(LocationFormatValidation.new("location" => {
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
        validation = LocationFormatValidation.new("location" => {
          "path" => "foo.rb",
          "positions" => "everywhere",
        })
        expect(validation).not_to be_valid
        expect(validation.message).to start_with("Location is not formatted correctly: location.positions is not valid")
      end

      it "returns false if the lines are badly formed" do
        validation = LocationFormatValidation.new("location" => {
          "path" => "foo.rb",
          "positions" => {
            "lines" => "all of them"
          }
        })
        expect(validation).not_to be_valid
        expect(validation.message).to start_with("Location is not formatted correctly: location.positions is not valid")
      end

      it "returns false if the location line values are not integers" do
        location = {
          "lines" => {
            "begin" => "1",
            "end" => "2"
          }
        }

        validation = LocationFormatValidation.new("location" => location)

        expect(validation).not_to be_valid
        expect(validation.message).to start_with("Location is not formatted correctly: location.lines is not valid")
      end

      it "returns false if the location position values are not integers" do
        location = {
          "positions" => {
            "begin" => {
              "line" => "1",
              "column" => "2"
            },
            "end" => {
              "offset" => "20"
            }
          }
        }

        validation = LocationFormatValidation.new("location" => location)

        expect(validation).not_to be_valid
        expect(validation.message).to start_with("Location is not formatted correctly: location.positions is not valid")
      end
    end
  end
end
