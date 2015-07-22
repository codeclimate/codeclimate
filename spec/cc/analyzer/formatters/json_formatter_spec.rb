require 'spec_helper'

module CC::Analyzer::Formatters
  describe JSONFormatter do
    describe "#write" do
      it "returns when no data is present" do
        formatter = JSONFormatter.new
        issue = Factory.sample_issue
        stdout, stderr = capture_io do
          formatter.engine_running(OpenStruct.new(name: "cool_engine")) do
            formatter.write(issue.to_json)
          end
        end

        stdout.must_match("")
      end
    end

    describe "#start, write, finished" do
      it "outputs a string that can be parsed as JSON" do
        issue1 = Factory.sample_issue
        issue2 = Factory.sample_issue

        formatter = JSONFormatter.new

        stdout, stderr = capture_io do
          formatter.started
          formatter.engine_running(OpenStruct.new(name: "cool_engine")) do
            formatter.write(issue1.to_json)
            formatter.write(issue2.to_json)
          end
          formatter.finished
        end

        parsed_json = JSON.parse(stdout)
        parsed_json.must_equal([{"type"=>"issue", "check"=>"Rubocop/Style/Documentation", "description"=>"Missing top-level class documentation comment.", "categories"=>["Style"], "remediation_points"=>10, "location"=>{"path"=>"lib/cc/analyzer/accumulator.rb", "begin"=>{"pos"=>32, "line"=>3}, "end"=>{"pos"=>37, "line"=>3}}, "engine_name"=>"cool_engine"}, {"type"=>"issue", "check"=>"Rubocop/Style/Documentation", "description"=>"Missing top-level class documentation comment.", "categories"=>["Style"], "remediation_points"=>10, "location"=>{"path"=>"lib/cc/analyzer/accumulator.rb", "begin"=>{"pos"=>32, "line"=>3}, "end"=>{"pos"=>37, "line"=>3}}, "engine_name"=>"cool_engine"}])
      end

      it "prints a correctly formatted array of comma separated JSON issues" do
        issue1 = Factory.sample_issue
        issue2 = Factory.sample_issue

        formatter = JSONFormatter.new

        stdout, stderr = capture_io do
          formatter.started
          formatter.engine_running(OpenStruct.new(name: "cool_engine")) do
            formatter.write(issue1.to_json)
            formatter.write(issue2.to_json)
          end
          formatter.finished
        end

        last_two_characters = stdout[stdout.length-2..stdout.length-1]

        stdout.first.must_match("[")
        last_two_characters.must_match("]\n")

        stdout.must_match("[{\"type\":\"issue\",\"check\":\"Rubocop/Style/Documentation\",\"description\":\"Missing top-level class documentation comment.\",\"categories\":[\"Style\"],\"remediation_points\":10,\"location\":{\"path\":\"lib/cc/analyzer/accumulator.rb\",\"begin\":{\"pos\":32,\"line\":3},\"end\":{\"pos\":37,\"line\":3}},\"engine_name\":\"cool_engine\"},\n{\"type\":\"issue\",\"check\":\"Rubocop/Style/Documentation\",\"description\":\"Missing top-level class documentation comment.\",\"categories\":[\"Style\"],\"remediation_points\":10,\"location\":{\"path\":\"lib/cc/analyzer/accumulator.rb\",\"begin\":{\"pos\":32,\"line\":3},\"end\":{\"pos\":37,\"line\":3}},\"engine_name\":\"cool_engine\"}]\n")
      end
    end
  end
end
