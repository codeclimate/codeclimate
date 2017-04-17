require "spec_helper"

module CC::Analyzer
  describe Issue do
    let(:output) do
      {
        "categories" => ["Style"],
        "check_name" => "Rubocop/Style/Documentation",
        "description" => "Missing top-level class documentation comment.",
        "location"=> {
          "lines" => {
            "begin" => 32,
            "end" => 40,
          },
          "path" => "lib/cc/analyzer/config.rb",
        },
        "remediation_points" => 10,
        "type" => "issue",
      }
    end

    it "allows access to keys as methods" do
      issue = Issue.new(output.to_json)

      expect(issue.respond_to?("check_name")).to eq true
      expect(issue.check_name).to eq("Rubocop/Style/Documentation")
    end

    describe "#fingerprint" do
      it "adds a fingerprint when it is missing" do
        issue = Issue.new(output.to_json)

        expect(issue.fingerprint).to eq "433fae1189b03bcd9153dc8dce209fa5"
      end

      it "doesn't overwrite fingerprints within output" do
        output["fingerprint"] = "foo"

        issue = Issue.new(output.to_json)

        expect(issue.fingerprint).to eq "foo"
      end

      it "uses the source fingerprint if env variable is present" do
        issue = Issue.new(output.to_json)

        expect(issue.fingerprint).to eq "433fae1189b03bcd9153dc8dce209fa5"
      end
    end

    describe "#as_json" do
      it "merges in defaulted attributes" do
        expected_additions = {
          "fingerprint" => "433fae1189b03bcd9153dc8dce209fa5",
          "severity" => Issue::DEFAULT_SEVERITY,
        }
        issue = Issue.new(output.to_json)

        expect(issue.as_json).to eq(output.merge(expected_additions))
      end

      it "doesn't overwrite defaulted attrs when present" do
        optional_attrs = {
          "fingerprint" => "433fae1189b03bcd9153dc8dce209fa5",
          "severity" => "major",
        }

        unchanged = output.merge(optional_attrs)

        issue = Issue.new(unchanged.to_json)

        expect(issue.as_json).to eq(unchanged)
      end
    end
  end
end
