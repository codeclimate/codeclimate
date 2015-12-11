require "spec_helper"

module CC::Analyzer
  describe Issue do
    it "allows access to keys as methods" do
      output = {
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
      }.to_json
      issue = Issue.new(output)

      issue.must_respond_to("check_name")
      issue.check_name.must_equal("Rubocop/Style/Documentation")
    end

    describe "#fingerprint" do
      it "adds a fingerprint when it is missing" do
        output = {
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
        }.to_json
        issue = Issue.new(output)

        issue.fingerprint.must_equal "9d20301efe0bbb8f87fb4eb15a71fc81"
      end

      it "doesn't overwrite fingerprints within output" do
        output = {
          "categories" => ["Style"],
          "check_name" => "Rubocop/Style/Documentation",
          "description" => "Missing top-level class documentation comment.",
          "fingerprint" => "foo",
          "location"=> {
            "lines" => {
              "begin" => 32,
              "end" => 40,
            },
            "path" => "lib/cc/analyzer/config.rb",
          },
          "remediation_points" => 10,
          "type" => "issue",
        }.to_json
        issue = Issue.new(output)

        issue.fingerprint.must_equal "foo"
      end
    end

    describe "#as_json" do
      it "merges in defaulted attributes" do
        output = {
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
        expected_additions = {
          "fingerprint" => "9d20301efe0bbb8f87fb4eb15a71fc81",
        }
        issue = Issue.new(output.to_json)

        issue.as_json.must_equal(output.merge(expected_additions))
      end
    end
  end
end
