require "spec_helper"

module CC::Analyzer
  describe IssueSorter do
    describe "#by_location" do
      it "orders items correctly" do
        issues = [
          whole_file_issue = { "location" => { } },
          lines_issue = { "location" => { "lines" => { "begin" => 3 } } },
          offsets_issue = { "location" => { "positions" => { "begin" => { "offset" => 600 } } } },
          linecol_issue = { "location" => { "positions" => { "begin" => { "line" => 4, "column" => 1} } } },
          linecol_issue2 = { "location" => { "positions" => { "begin" => { "line" => 4, "column" => 2} } } },
        ]

        IssueSorter.new(issues).by_location.must_equal([
          whole_file_issue, lines_issue, linecol_issue,
          linecol_issue2, offsets_issue
        ])
      end
    end
  end
end
