require "spec_helper"

module CC::Analyzer
  describe SourceExtractor do
    describe "#extract" do
      let(:source) { source = "class\n  def foo\n    p 'bar'\n  end\nend\n" }
      let(:extractor) { SourceExtractor.new(source) }

      it "extracts the source relavant to lines" do
        location = {
          "lines" => {
            "begin" => 2,
            "end" => 4,
          },
        }

        expect(extractor.extract(location)).to eq("  def foo\n    p 'bar'\n  end\n")
      end

      it "extracts the source relavant to position offsets" do
        location = {
          "positions" => {
            "begin" => { "offset" => 8 },
            "end" => { "offset" => 14 }
          },
        }

        expect(extractor.extract(location)).to eq("def foo")
      end

      it "extracts the source relavant to position coordinates" do
        location = {
          "positions" => {
            "begin" => { "line" => 2, "column" => 3 },
            "end" => { "line" => 3, "column" => 11 }
          },
        }

        expect(extractor.extract(location)).to eq("def foo\n    p 'bar'")
      end

      it "raises an exception if position format is invalid" do
        location = {
          "positions" => {
            "begin" => { "wrong" => 2, "key" => 3 },
            "end" => { "wrong" => 3, "key" => 11 }
          },
        }

        expect{ extractor.extract(location) }.to raise_error(
          SourceExtractor::InvalidLocation
        )
      end

      it "raises an exception if positions format is invalid in another way" do
        location = {
          "positions" => {
            "begin" => { "line" => 2, "end" => 3 },
            "end" => { "line" => 3, "end" => nil }
          },
        }

        expect{ extractor.extract(location) }.to raise_error(
          SourceExtractor::InvalidLocation
        )
      end
    end
  end
end
