module Factory
  extend self

  def yaml_with_rubocop_enabled
    %{
    engines:
      rubocop:
        enabled: true
    }
  end

  def yaml_without_rubocop_enabled
    %{
    engines:
      rubocop:
        enabled: false
    }
  end

  def yaml_without_jshint
  %{
    engines:
      rubocop:
        enabled: false
    }
  end

  def create_correct_yaml
    %{
      engines:
        rubocop:
          enabled: true
    }
  end

  def create_yaml_with_no_engines
    %{
      engines:
    }
  end

  def sample_issue(options = {})
    {
      "type" => "issue",
      "check_name" => "Rubocop/Style/Documentation",
      "description" => "Missing top-level class documentation comment.",
      "categories" => ["Style"],
      "remediation_points" => 10,
      "location"=> {
        "path" => "spec/fixtures/source2.rb",
        "lines" => {
          "begin" => 2,
          "end" => 9,
        },
      }
    }.merge(options)
  end
end

RSpec.configure do |conf|
  conf.include(Factory)
end
