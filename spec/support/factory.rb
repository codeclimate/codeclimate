module Factory
  extend self

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
