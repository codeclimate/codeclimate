require "spec_helper"

describe CC::Config::Validation::JSON do
  it "is valid for a complete config" do
    validator = validate_json(<<-EOJSON)
    {
      "version": "2",
      "prepare": {
        "fetch": [
          "http://test.test/rubocop.yml",
          {
            "url": "http://test.test/myeslint.json",
            "path": "eslint.json"
          }
        ]
      },
      "checks": {
        "method-complexity": {
          "enabled": false
        }
      },
      "plugins": {
        "rubocop": {
          "enabled": true,
          "channel": "beta",
          "config": { "file": "foobar" }
        },
        "eslint": {
          "enabled": true,
          "config": "bazfoo"
        },
        "hlint": true
      },
      "exclude_patterns": [
        "**/*.rb",
        "foo/"
      ]
    }
    EOJSON

    expect(validator).to be_valid
    expect(validator.warnings.length).to eq(0)
  end

  it "handles unparseable json" do
    validator = validate_json("{")

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/Unable to parse:/)
  end

  it "handles parseable but non-hash json" do
    validator = validate_json(%{["foo", "bar"]})

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/Config file should contain a hash/)
  end

  it "reports error for hash fetch" do
    validator = validate_json(<<-EOJSON)
    {
      "prepare": {
        "fetch": {
          "rubocop": "http://test.test/rubocop.yml"
        }
      }
    }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include("prepare section: 'fetch' must be an array")
  end

  it "reports errors for fetch with invalid URL or missing path" do
    validator = validate_json(<<-EOJSON)
    {
      "prepare": {
        "fetch": [
          "test.test/rubocop.yml",
          { "url": "http://test.test/myeslint.json" }
        ]
      }
    }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include(%r{invalid URL 'test.test/rubocop.yml'})
    expect(validator.errors).to include(/must include 'url' & 'path'/)
  end

  it "reports errors for fetch with invalid paths" do
    validator = validate_json(<<-EOJSON)
    {
      "prepare": {
        "fetch": [
          {
            "url": "http://test.test/myeslint.json",
            "path": null
          },
          {
            "url": "http://test.test/myeslint.json",
            "path": "/etc/passwd"
          },
          {
            "url": "http://test.test/myeslint.json",
            "path": "../../htaccess"
          }
        ]
      }
    }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/'path' cannot be empty/)
    expect(validator.errors).to include(%r{absolute path '/etc/passwd' is invalid})
    expect(validator.errors).to include(%r{relative path elements in '../../htaccess' are invalid})
  end

  it "reports errors for array plugins" do
    validator = validate_json(<<-EOJSON)
    { "plugins": [ "rubocop" ] }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/'plugins' must be a hash/)
  end

  it "reports errors for invalid stringy engine config" do
    validator = validate_json(<<-EOJSON)
    { "plugins": { "rubocop": "foobar" } }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include("engine rubocop: section must be a boolean or a hash")
  end

  it "reports errors for engine config with invalid contents" do
    validator = validate_json(<<-EOJSON)
    {
      "plugins": {
        "rubocop": {
          "enabled": "foobar",
          "config": false
        }
      }
    }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include("engine rubocop: 'enabled' must be a boolean")
    expect(validator.errors).to include("engine rubocop: 'config' must be one of string, hash")
  end

  it "reports errors for array checks" do
    validator = validate_json(<<-EOJSON)
    { "checks": [ "foo" ] }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/'checks' must be a hash/)
  end

  it "reports errors for check with boolean config" do
    validator = validate_json(<<-EOJSON)
    { "checks": { "foo": false } }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include("check foo: must be a hash")
  end

  it "reports errors for check with invalid config" do
    validator = validate_json(<<-EOJSON)
    {
      "checks": {
        "foo": {
          "enabled": "foobar",
          "config": false
        }
      }
    }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include("check foo: 'enabled' must be a boolean")
    expect(validator.errors).to include("check foo: 'config' must be a hash")
  end

  it "reports errors for singular string exclude patterns" do
    validator = validate_json(<<-EOJSON)
    { "exclude_patterns": "foobar" }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include("'exclude_patterns' must be an array")
  end

  it "reports errors for errors within exclude_patterns" do
    validator = validate_json(<<-EOJSON)
    {
      "exclude_patterns": [
        { "foo": "bar" }
      ]
    }
    EOJSON

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/each exclude pattern should be a string/)
  end

  it "reports warnings for unrecognized keys" do
    validator = validate_json(<<-EOJSON)
    {
      "plugins": {
        "rubocop": {
          "enalbed": false
        }
      },
      "exclude_pattttttterns": [ "foo" ]
    }
    EOJSON

    expect(validator).to be_valid
    expect(validator.warnings).to include("engine rubocop: unrecognized key 'enalbed'")
    expect(validator.warnings).to include("unrecognized key 'exclude_pattttttterns'")
  end

  describe "version validation" do
    it "warns about missing version" do
      validator = validate_json(<<-EOJSON)
      { "plugins": {} }
      EOJSON

      expect(validator).to be_valid
      expect(validator.warnings).to include(%{missing 'version' key. Please add `"version": "2"`})
    end
  end

  describe "engine checks" do
    it "is valid for valid usage" do
      validator = validate_json(<<-EOJSON)
      {
        "plugins": {
          "rubocop": {
            "checks": {
              "Foo": { "enabled": false }
            }
          }
        }
      }
      EOJSON

      expect(validator).to be_valid
    end

    it "errors for the wrong type" do
      validator = validate_json(<<-EOJSON)
      {
        "plugins": {
          "rubocop": {
            "checks": [ "Foo" ]
          }
        }
      }
      EOJSON

      expect(validator).not_to be_valid
      expect(validator.errors).to include("engine rubocop: 'checks' must be a hash")
    end
  end

  describe "exclude_fingerprints" do
    it "allows valid usage" do
      validator = validate_json(<<-EOJSON)
      {
        "plugins": {
          "rubocop": {
            "exclude_fingerprints": [ "foo" ]
          }
        }
      }
      EOJSON

      expect(validator).to be_valid
    end

    it "errors for the wrong type" do
      validator = validate_json(<<-EOJSON)
      {
        "plugins": {
          "rubocop": {
            "exclude_fingerprints": "foo"
          }
        }
      }
      EOJSON

      expect(validator).not_to be_valid
      expect(validator.errors).to include("engine rubocop: 'exclude_fingerprints' must be an array")
    end
  end


  def validate_json(json, registry = nil)
    Tempfile.open("") do |tmp|
      tmp.puts(json)
      tmp.rewind

      registry ||= double(:engine_registry, fetch_engine_details: {})
      described_class.new(tmp.path, registry)
    end
  end
end
