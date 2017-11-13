require "spec_helper"

module CC::Analyzer
  describe IssueValidator do
    describe "#valid?" do
      it "returns true when everything is valid" do
        valid_issue = {
          "categories" => ["Security"],
          "check_name" => "Insecure Dependency",
          "description" => "RDoc 2.3.0 through 3.12 XSS Exploit",
          "engine_name" => "bundler-audit",
          "location" => {
            "lines" => { "begin" => 140, "end" => 140 },
            "path" => "Gemfile.lock",
          },
          "remediation_points" => 500_000,
          "type" => "Issue",
        }

        validator = IssueValidator.new(valid_issue)

        expect(validator).to be_valid
      end

      it "stores an error for invalid issues" do
        allow(CC::Analyzer.logger).to receive(:error)
        validator = IssueValidator.new({})
        expect(validator).not_to be_valid
        expect(validator.error).to eq(
          message: "Category must be at least one of Bug Risk, Clarity, Compatibility, Complexity, Duplication, Performance, Security, Style; Check name must be present; Description must be present; Location is not formatted correctly: location.lines or location.positions must be present; File does not exist: ''; Path is not a file: ''; Path must be present; Path must be relative to the project directory; Type must be 'issue' but was '': `{}`.",
          document: {},
        )
      end
    end
  end
end
