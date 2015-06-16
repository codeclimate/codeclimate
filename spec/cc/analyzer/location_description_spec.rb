require "spec_helper"

module CC::Analyzer
  describe LocationDescription do
    describe "#to_s" do
      it "adds the suffix" do
        location = {"lines" => {"begin" => 1, "end" => 3}}

        LocationDescription.new(location, "!").to_s.must_equal("1-3!")
      end

      it "with lines" do
        location = {"lines" => {"begin" => 1, "end" => 3}}

        LocationDescription.new(location).to_s.must_equal("1-3")
      end

      it "with linecols" do
        location = {
          "positions" => {
            "begin" => {
              "line" => 1,
              "column" => 2
            },
            "end" => {
              "line" => 3,
              "column" => 4
            }
          }
        }

        LocationDescription.new(location).to_s.must_equal("1:2-3:4")
      end

      it "with offsets" do
        location = {
          "positions" => {
            "begin" => {
              "offset" => 111
            },
            "end" => {
              "offset" => 122
            }
          }
        }

        LocationDescription.new(location).to_s.must_equal("111-122")
      end
    end
  end
end
