require "spec_helper"

module CC::Analyzer
  describe IssueSorter do
    describe "#by_location" do
      it "orders items correctly" do
        issues = [
          whole_file = { "location" => { } },
          offset_600 = { "location" => { "positions" => { "begin" => { "offset" => 600 } } } },
          line_3 = { "location" => { "lines" => { "begin" => 3 } } },
          line_4 = { "location" => { "lines" => { "begin" => 4 } } },
          line_15 = { "location" => { "lines" => { "begin" => 15 } } },
          line_4_col_1 = { "location" => { "positions" => { "begin" => { "line" => 4, "column" => 1} } } },
          line_4_col_2 = { "location" => { "positions" => { "begin" => { "line" => 4, "column" => 2} } } },
          line_4_col_83 = { "location" => { "positions" => { "begin" => { "line" => 4, "column" => 83} } } },
          line_1_col_50 = { "location" => { "positions" => { "begin" => { "line" => 1, "column" => 50} } } },
        ].shuffle

        sorted = IssueSorter.new(issues).by_location
        expect(sorted).to eq([
          whole_file,
          line_1_col_50,
          line_3,
          line_4,
          line_4_col_1,
          line_4_col_2,
          line_4_col_83,
          line_15,
          offset_600,
        ])
      end
    end
  end
end
