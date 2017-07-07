require "spec_helper"

module CC
  module Analyzer
    describe EngineOutputOverrider do
      it "does not modify arbitrary json" do
        output = EngineOutput.new("", %({"arbitrary":"json"}))
        expect(subject.apply(output)).to eq output
      end

      it "overrides issue severity" do
        issue = build_issue("severity" => "major")

        overrider = described_class.new(
          "enabled" => true,
          "issue_override" => {
            "severity" => "info",
          },
        )

        expect(overrider.apply(issue)["severity"]).to eq "info"
      end

      def build_issue(attributes)
        EngineOutput.new("", {
          "type" => EngineOutputFilter::ISSUE_TYPE,
          "check_name" => "rubocop",
          "location" => {
            "path" => "spec/fixtures/source.rb",
            "lines" => { "begin" => 13, "end" => 14 },
          },
        }.merge(attributes).to_json)
      end
    end
  end
end
