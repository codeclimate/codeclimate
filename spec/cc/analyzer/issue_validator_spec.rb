require "spec_helper"

module CC::Analyzer
  describe IssueValidator do
    describe "#validate" do
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

        expect(validator.validate).to eq(true)
      end

      it "stores an error for invalid issues" do
        CC::Analyzer.logger.stubs(:error) # quiet spec
        validator = IssueValidator.new({})
        expect(validator.validate).to eq(false)
        expect(validator.error).to eq(
          message: "Check name must be present, Path must be present, Path must be relative, Type must be 'issue' but was '': `{}`.",
          issue: {},
        )
      end
    end
  end
end
