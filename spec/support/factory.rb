module Factory
  def sample_issue
    {
      "type" => "issue",
      "check" => "Rubocop/Style/Documentation",
      "description" => "Missing top-level class documentation comment.",
      "categories" => ["Style"],
      "remediation_points" => 10,
      "location"=> {
        "path" => "lib/cc/analyzer/accumulator.rb",
        "begin" => {
          "pos" => 32,
          "line" => 3
        },
        "end"=> {
          "pos" => 37,
          "line" => 3
        }
      }
    }
  end
end
