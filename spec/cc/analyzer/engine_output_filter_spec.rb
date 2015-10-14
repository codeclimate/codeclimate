require "spec_helper"

module CC::Analyzer
  describe EngineOutputFilter do
    it "filters empty output" do
      filter = EngineOutputFilter.new

      filter.filter?("").must_equal true
      filter.filter?(" ").must_equal true
      filter.filter?("\n").must_equal true
    end

    it "does not filter arbitrary output" do
      filter = EngineOutputFilter.new

      filter.filter?("abritrary output").must_equal false
    end

    it "does not filter arbitrary json" do
      filter = EngineOutputFilter.new

      filter.filter?(%{{"arbitrary":"json"}}).must_equal nil
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

      filter.filter?(foo_issue.to_json).must_equal false
      filter.filter?(bar_issue.to_json).must_equal false
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

      filter.filter?(issue.to_json).must_equal true
    end

    it "filters issues ignored in the config even if the type has the wrong case" do
      issue = {
        "type" => "Issue", "check_name" => "foo",
      }

      filter = EngineOutputFilter.new(
        engine_config(
          "checks" => {
            "foo" => { "enabled" => false },
          }
        )
      )

      filter.filter?(issue.to_json).must_equal true
    end

    def build_issue(check_name)
      {
        "type" => EngineOutputFilter::ISSUE_TYPE,
        "check_name" => check_name,
      }
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
