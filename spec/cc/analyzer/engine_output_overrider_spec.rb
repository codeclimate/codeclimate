require "spec_helper"

module CC
  module Analyzer
    describe EngineOutputOverrider do
      it "does not modify arbitrary json" do
        output = EngineOutput.new(%({"arbitrary":"json"}))
        expect(subject.apply(output)).to eq output
      end

      it "overrides issue severity" do
        issue = build_issue("severity" => "major")

        overrider = described_class.new(
          engine_config(
            "issue_override" => {
              "severity" => "info",
            },
          ),
        )

        expect(overrider.apply(issue)["severity"]).to eq "info"
      end

      def build_issue(attributes)
        EngineOutput.new({
          "type" => EngineOutputFilter::ISSUE_TYPE,
          "check_name" => "rubocop",
          "location" => {
            "path" => "spec/fixtures/source.rb",
            "lines" => { "begin" => 13, "end" => 14 },
          },
        }.merge(attributes).to_json)
      end

      def engine_config(hash)
        codeclimate_yaml = {
          "engines" => {
            "rubocop" => hash.merge("enabled" => true),
          },
        }.to_yaml

        CC::Yaml.parse(codeclimate_yaml).engines["rubocop"]
      end
    end
  end
end
