require "spec_helper"

describe CC::Config::Validation::YAML do
  it "is valid for a complete config" do
    validator = validate_yaml(<<-EOYAML)
    version: "2"
    prepare:
      fetch:
      - http://test.test/rubocop.yml
      - url: http://test.test/myeslint.json
        path: eslint.json
    checks:
      method-complexity:
        enabled: false
    plugins:
      rubocop:
        enabled: true
        channel: beta
        exclude_patterns:
        - foo
        config:
          file: "foobar"
      eslint:
        enabled: true
        config: "bazfoo"
      hlint: true
    exclude_patterns:
    - "**/*.rb"
    - foo/
    EOYAML

    expect(validator).to be_valid
    expect(validator.warnings.length).to eq(0)
  end

  it "handles legacy config with engine excludes" do
    validator = validate_yaml(<<-EOYAML)
    engines:
      rubocop:
        exclude_paths:
        - foo
    exclude_paths:
    - bar
    EOYAML

    expect(validator).to be_valid
    expect(validator.warnings).not_to include(a_string_matching(/unrecognized key/))
    expect(validator.warnings).to include(a_string_starting_with(
      "engine rubocop: 'exclude_paths' has been deprecated"
    ))
  end

  it "handles legacy config with engine excludes as a string" do
    validator = validate_yaml(<<-EOYAML)
    engines:
      rubocop:
        exclude_paths:
          foo
    exclude_paths:
      bar
    EOYAML

    validator.valid?

    expect(validator).to be_valid
    expect(validator.warnings).not_to include(a_string_matching(/unrecognized key/))
  end

  it "handles unparseable yaml" do
    validator = validate_yaml("yargle: poskgp;aerwet ;rgr:  ")

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/Unable to parse:/)
  end

  it "handles parseable but non-hash yaml" do
    validator = validate_yaml("- foo\n- bar\n")

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/Config file should contain a hash/)
  end

  it "reports error for hash fetch" do
    validator = validate_yaml(<<-EOYAML)
    prepare:
      fetch:
        rubocop: http://test.test/rubocop.yml
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include("prepare section: 'fetch' must be an array")
  end

  it "reports errors for fetch with invalid URL or missing path" do
    validator = validate_yaml(<<-EOYAML)
    prepare:
      fetch:
      - test.test/rubocop.yml
      - url: http://test.test/myeslint.json
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include(%r{invalid URL 'test.test/rubocop.yml'})
    expect(validator.errors).to include(/must include 'url' & 'path'/)
  end

  it "reports errors for fetch with invalid paths" do
    validator = validate_yaml(<<-EOYAML)
    prepare:
      fetch:
      - url: http://test.test/myeslint.json
        path:
      - url: http://test.test/myeslint.json
        path: /etc/passwd
      - url: http://test.test/myeslint.json
        path: ../../htaccess
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/'path' cannot be empty/)
    expect(validator.errors).to include(%r{absolute path '/etc/passwd' is invalid})
    expect(validator.errors).to include(%r{relative path elements in '../../htaccess' are invalid})
  end

  it "reports errors for array plugins" do
    validator = validate_yaml(<<-EOYAML)
    plugins:
    - rubocop
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/'plugins' must be a hash/)
  end

  it "reports errors for invalid stringy engine config" do
    validator = validate_yaml(<<-EOYAML)
    plugins:
      rubocop: foobar
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include("engine rubocop: section must be a boolean or a hash")
  end

  it "reports errors for engine config with invalid contents" do
    validator = validate_yaml(<<-EOYAML)
    plugins:
      rubocop:
        enabled: foobar
        config: false
        exclude_patterns: nope
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include("engine rubocop: 'enabled' must be a boolean")
    expect(validator.errors).to include("engine rubocop: 'config' must be one of string, hash")
    expect(validator.errors).to include("engine rubocop: 'exclude_patterns' must be an array")
  end

  it "reports errors for array checks" do
    validator = validate_yaml(<<-EOYAML)
    checks:
    - foo
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/'checks' must be a hash/)
  end

  it "reports errors for check with boolean config" do
    validator = validate_yaml(<<-EOYAML)
    checks:
      foo: false
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include("check foo: must be a hash")
  end

  it "reports errors for check with invalid config" do
    validator = validate_yaml(<<-EOYAML)
    checks:
      foo:
        enabled: foobar
        config: false
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include("check foo: 'enabled' must be a boolean")
    expect(validator.errors).to include("check foo: 'config' must be a hash")
  end

  it "reports errors for singular string exclude patterns" do
    validator = validate_yaml(<<-EOYAML)
    exclude_patterns: foobar
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include("'exclude_patterns' must be an array")
  end

  it "reports errors for errors within exclude_patterns" do
    validator = validate_yaml(<<-EOYAML)
    exclude_patterns:
    - foo: bar
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include(/each exclude pattern should be a string/)
  end

  it "reports errors for conflicting keys" do
    validator = validate_yaml(<<-EOYAML)
    engines:
      rubocop:
        enabled: true
    plugins:
      eslint:
        enabled: true
    exclude_paths:
    - bar
    exclude_patterns:
    - foo
    EOYAML

    expect(validator).not_to be_valid
    expect(validator.errors).to include("only use one of 'engines', 'plugins'")
    expect(validator.errors).to include("only use one of 'exclude_paths', 'exclude_patterns'")
  end

  it "reports warnings for deprecated keys" do
    validator = validate_yaml(<<-EOYAML)
    engines:
      rubocop:
        enabled: true
    ratings:
      paths:
      - foo
    exclude_paths:
    - bar
    EOYAML

    expect(validator).to be_valid
    expect(validator.warnings).to include("'ratings' has been deprecated, and will not be used")
    expect(validator.warnings).to include("'engines' has been deprecated, please use 'plugins' instead")
    expect(validator.warnings).to include("'exclude_paths' has been deprecated, please use 'exclude_patterns' instead")
  end

  it "reports warnings for unrecognized keys" do
    validator = validate_yaml(<<-EOYAML)
    engines:
      rubocop:
        enabbled: false
    exclude_pattttttterns:
    - foo
    EOYAML

    expect(validator).to be_valid
    expect(validator.warnings).to include("engine rubocop: unrecognized key 'enabbled'")
    expect(validator.warnings).to include("unrecognized key 'exclude_pattttttterns'")
  end

  describe "version validation" do
    it "does not warn about version for v1 schema" do
      validator = validate_yaml(<<-EOYAML)
      engines: {}
      EOYAML

      expect(validator).to be_valid
      expect(validator.warnings).not_to include(%{missing 'version' key. Please add `version: "2"`})
    end

    it "does warn about version for v2 schema" do
      validator = validate_yaml(<<-EOYAML)
      plugins: {}
      EOYAML

      expect(validator).to be_valid
      expect(validator.warnings).to include(%{missing 'version' key. Please add `version: "2"`})
    end
  end

  describe "engine checks" do
    it "is valid for valid usage" do
      validator = validate_yaml(<<-EOYAML)
      plugins:
        rubocop:
          checks:
            Foo:
              enabled: false
      EOYAML

      expect(validator).to be_valid
    end

    it "errors for the wrong type" do
      validator = validate_yaml(<<-EOYAML)
      plugins:
        rubocop:
          checks:
            - Foo
      EOYAML

      expect(validator).not_to be_valid
      expect(validator.errors).to include("engine rubocop: 'checks' must be a hash")
    end
  end

  describe "exclude_fingerprints" do
    it "allows valid usage" do
      validator = validate_yaml(<<-EOYAML)
      plugins:
        rubocop:
          exclude_fingerprints:
            - foo
      EOYAML

      expect(validator).to be_valid
    end

    it "errors for the wrong type" do
      validator = validate_yaml(<<-EOYAML)
      plugins:
        rubocop:
          exclude_fingerprints: Foo
      EOYAML

      expect(validator).not_to be_valid
      expect(validator.errors).to include("engine rubocop: 'exclude_fingerprints' must be an array")
    end
  end

  def validate_yaml(yaml, registry = nil)
    Tempfile.open("") do |tmp|
      tmp.puts(yaml)
      tmp.rewind

      registry ||= double(:engine_registry, fetch_engine_details: {})
      described_class.new(tmp.path, registry)
    end
  end
end
