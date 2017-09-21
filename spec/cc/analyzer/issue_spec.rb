require "spec_helper"

module CC::Analyzer
  describe Issue do
    let(:output) do
      sample_issue
    end

    it "allows access to keys as methods" do
      issue = Issue.new("", output.to_json)

      expect(issue.respond_to?("check_name")).to eq true
      expect(issue.check_name).to eq("Rubocop/Style/Documentation")
    end

    describe "#fingerprint" do
      it "adds a fingerprint when it is missing" do
        issue = Issue.new("", output.to_json)

        expect(issue.fingerprint).to eq "6d6cd30cd53e7566fb681eb3239a3cf4"
      end

      it "raises a helpful error when the location is malformed" do
        output["location"] = {
          "path" =>  "foo.js",
          "positions" => {
            "begin" => {
              "line" => 3,
              "column" => nil,
            },
            "end" => {
              "line" => 7,
              "column" => 9,
            },
          },
        }
        issue = Issue.new("", output.to_json)

        expect { issue.fingerprint }.to raise_error SourceExtractor::InvalidLocation
      end

      it "doesn't overwrite fingerprints within output" do
        output["fingerprint"] = "foo"

        issue = Issue.new("", output.to_json)

        expect(issue.fingerprint).to eq "foo"
      end
    end

    describe "#as_json" do
      it "merges in defaulted attributes" do
        expected_additions = {
          "engine_name" => "foo",
          "fingerprint" => "6d6cd30cd53e7566fb681eb3239a3cf4",
          "severity" => Issue::DEFAULT_SEVERITY,
        }
        issue = Issue.new("foo", output.to_json)

        expect(issue.as_json).to eq(output.merge(expected_additions))
      end

      it "maps deprecated severity to default" do
        expected_additions = {
          "engine_name" => "",
          "fingerprint" => "6d6cd30cd53e7566fb681eb3239a3cf4",
          "severity" => Issue::DEFAULT_SEVERITY,
        }
        issue = Issue.new("", output.merge({ "severity" => Issue::DEPRECATED_SEVERITY }).to_json)

        expect(issue.as_json).to eq(output.merge!(expected_additions))
      end

      it "doesn't overwrite defaulted attrs when present" do
        optional_attrs = {
          "engine_name" => "foo",
          "fingerprint" => "433fae1189b03bcd9153dc8dce209fa5",
          "severity" => "major",
        }

        unchanged = output.merge(optional_attrs)

        issue = Issue.new("", unchanged.to_json)

        expect(issue.as_json).to eq(unchanged)
      end
    end
  end
end
