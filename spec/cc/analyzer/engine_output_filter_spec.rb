require "spec_helper"

module CC::Analyzer
  describe EngineOutputFilter do
    it "does not filter arbitrary json" do
      filter = EngineOutputFilter.new

      expect(filter.filter?(EngineOutput.new("", %{{"arbitrary":"json"}}))).to eq false
    end

    it "does not filter issues missing or enabled in the config" do
      foo_issue = build_issue("foo")
      bar_issue = build_issue("bar")

      filter = EngineOutputFilter.new(
        engine_config(
          "checks" => {
            "foo" => { "enabled" => true },
          }
        )
      )

      expect(filter.filter?(foo_issue)).to eq false
      expect(filter.filter?(bar_issue)).to eq false
    end

    it "filters issues ignored in the config" do
      issue = build_issue("foo")

      filter = EngineOutputFilter.new(
        engine_config(
          "checks" => {
            "foo" => { "enabled" => false },
          }
        )
      )

      expect(filter.filter?(issue)).to eq true
    end

    it "filters issues ignored in the config even if the type has the wrong case" do
      issue = EngineOutput.new("", {
        "type" => "Issue", "check_name" => "foo",
      }.to_json)

      filter = EngineOutputFilter.new(
        engine_config(
          "checks" => {
            "foo" => { "enabled" => false },
          }
        )
      )

      expect(filter.filter?(issue)).to eq true
    end

    it "filters issues with a fingerprint that matches exclude_fingerprints" do
      issue = EngineOutput.new("", {
        "type" => "Issue",
        "check_name" => "foo",
        "fingerprint" => "05a33ac5659c1e90cad1ce32ff8a91c0",
        "location" => {
          "path" => "spec/fixtures/source.rb",
          "lines" => {
            "begin" => 13,
            "end" => 14,
          },
        },
      }.to_json)

      filter = EngineOutputFilter.new(
        engine_config(
          "exclude_fingerprints" => [
            "05a33ac5659c1e90cad1ce32ff8a91c0"
          ]
        )
      )

      expect(filter.filter?(issue)).to eq true
    end

    it "filters issues with an inferred fingerprint that matches exclude_fingerprints" do
      issue = EngineOutput.new("", {
        "type" => "Issue",
        "check_name" => "foo",
        "location" => {
          "path" => "spec/fixtures/source.rb",
          "lines" => {
            "begin" => 13,
            "end" => 14,
          },
        },
      }.to_json)

      filter = EngineOutputFilter.new(
        engine_config(
          "exclude_fingerprints" => [
            "295849af8407b3407bcfe21dfeb50ad8"
          ]
        )
      )

      expect(filter.filter?(issue)).to eq true
    end

    it "does not filter out issues with an inferred fingerprint that cannot be inferred" do
      issue = EngineOutput.new("", {
        "type" => "Issue",
        "check_name" => "foo",
        "location" => {
          "path" => "spec/fixtures/source.rb",
          "lines" => {
            "begin" => 13,
            "end" => nil,
          },
        },
      }.to_json)

      filter = EngineOutputFilter.new(
        engine_config(
          "exclude_fingerprints" => [
            "295849af8407b3407bcfe21dfeb50ad8"
          ]
        )
      )

      expect(filter.filter?(issue)).to eq false
    end

    def build_issue(check_name)
      EngineOutput.new("", {
        "type" => EngineOutputFilter::ISSUE_TYPE,
        "check_name" => check_name,
        "location" => {
          "path" => "spec/fixtures/source.rb",
          "lines" => {
            "begin" => 13,
            "end" => 14,
          },
        },
      }.to_json)
    end

    def engine_config(hash)
      hash.merge("enabled" => true)
    end
  end
end
