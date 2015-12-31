require "spec_helper"

describe "codeclimate-validate-config" do
  it "errors when .codeclimate.yml doesn't exist" do
    child = run_validate_config

    expect(child).not_to be_success
    expect(child.out).to be_empty
    expect(child.err).to match(/^ERROR: No '\.codeclimate\.yml' file found/)
  end

  it "emits errors and warnings" do
    write_codeclimate_yaml(<<-EOYAML)
      madeup: value
    EOYAML

    child = run_validate_config

    expect(child).not_to be_success
    expect(child.err).to match(/^ERROR: No languages or engines key found/)
    expect(child.err).to match(/^WARNING: unexpected key \"madeup\"/)
  end

  it "emits nested warnings" do
    write_codeclimate_yaml(<<-EOYAML)
      engines:
        rubocop:
          enabled: true
          unexpected:
            - one
            - two
    EOYAML

    child = run_validate_config

    expect(child.err).to match(/^WARNING in engines: unexpected key \"unexpected\"/)
  end

  it "considers warnings fatal if-and-only-if --strict" do
    write_codeclimate_yaml(<<-EOYAML)
      engines:
        rubocop:
          enabled: true
      madeup: value
    EOYAML

    child = run_validate_config
    strict_child = run_validate_config("--strict")

    expect(child).to be_success
    expect(strict_child).not_to be_success
  end
end
