require "spec_helper"

module CC::Analyzer
  describe EngineOutputFilter do
    include Factory

    it "filters empty output" do
      filter = EngineOutputFilter.new

      filter.filter?("").must_equal true
      filter.filter?(" ").must_equal true
      filter.filter?("\n").must_equal true
    end

    it "does raises builder error on arbitrary output" do
      filter = EngineOutputFilter.new

      (-> { filter.filter?("abritrary output") }).must_raise CC::Analyzer::Engine::OutputInvalid
    end

    it "does not filter issues missing or enabled in the config" do
      foo_issue = sample_issue_json("check_name" => "foo")
      bar_issue = sample_issue_json("check_name" => "bar")

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
      issue = sample_issue_json("check_name" => "foo")

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
      issue = sample_issue_json("fingerprint" => "05a33ac5659c1e90cad1ce32ff8a91c0")

      filter = EngineOutputFilter.new(
        engine_config(
          "exclude_fingerprints" => [
            "05a33ac5659c1e90cad1ce32ff8a91c0"
          ]
        )
      )

      filter.filter?(issue).must_equal true
    end

    it "filters issues with a generated fingerprint that matches exclude_fingerprints" do
      issue = sample_issue_json
      fingerprint = "05a33ac5659c1e90cad1ce32ff8a91c0"

      filter = EngineOutputFilter.new(
        engine_config("exclude_fingerprints" => [fingerprint])
      )

      Issue::Adapter.any_instance.stubs(:default_fingerprint).returns(fingerprint)
      filter.filter?(issue).must_equal true
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
