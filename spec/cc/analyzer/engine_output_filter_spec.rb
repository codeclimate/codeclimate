require "spec_helper"

module CC::Analyzer
  describe EngineOutputFilter do
    it "does not filter arbitrary json" do
      filter = EngineOutputFilter.new

      filter.filter?(EngineOutput.new(%{{"arbitrary":"json"}})).must_equal false
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

      filter.filter?(foo_issue).must_equal false
      filter.filter?(bar_issue).must_equal false
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

      filter.filter?(issue).must_equal true
    end

    it "filters issues ignored in the config even if the type has the wrong case" do
      issue = EngineOutput.new({
        "type" => "Issue", "check_name" => "foo",
      }.to_json)

      filter = EngineOutputFilter.new(
        engine_config(
          "checks" => {
            "foo" => { "enabled" => false },
          }
        )
      )

      filter.filter?(issue).must_equal true
    end

    it "filters issues with a fingerprint that matches exclude_fingerprints" do
      issue = EngineOutput.new({
        "type" => "Issue",
        "check_name" => "foo",
        "fingerprint" => "05a33ac5659c1e90cad1ce32ff8a91c0"
      }.to_json)

      filter = EngineOutputFilter.new(
        engine_config(
          "exclude_fingerprints" => [
            "05a33ac5659c1e90cad1ce32ff8a91c0"
          ]
        )
      )

      filter.filter?(issue).must_equal true
    end

    def build_issue(check_name)
      EngineOutput.new({
        "type" => EngineOutputFilter::ISSUE_TYPE,
        "check_name" => check_name,
      }.to_json)
    end

    def engine_config(hash)
      codeclimate_yaml = {
        "engines" => {
          "rubocop" => hash.merge("enabled" => true)
        }
      }.to_yaml

      CC::Yaml.parse(codeclimate_yaml).engines["rubocop"]
    end
  end
end
