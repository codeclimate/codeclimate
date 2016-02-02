require "spec_helper"

module CC::Analyzer
  describe LocationDescription do
    describe "#to_s" do
      it "adds the suffix" do
        location = { "lines" => { "begin" => 1, "end" => 3 } }

        expect(LocationDescription.new(Object.new, location, "!").to_s).to eq("1-3!")
      end

      it "with lines" do
        location = {"lines" => {"begin" => 1, "end" => 3}}

        expect(LocationDescription.new(Object.new, location).to_s).to eq("1-3")
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

        expect(LocationDescription.new(Object.new, location).to_s).to eq("1-3")
      end

      it "with offsets" do
        location = {
          "positions" => {
            "begin" => {
              "offset" => 1
            },
            "end" => {
              "offset" => 5
            }
          }
        }

        source_buffer = SourceBuffer.new("foo.rb", "foo\nbar")
        expect(LocationDescription.new(source_buffer, location).to_s).to eq("1-2")
      end
    end
  end
end
