require 'spec_helper'

module CC::Analyzer::Formatters
  describe JSONFormatter do
    include Factory

    describe "#write" do
      it "returns when no data is present" do
        formatter = JSONFormatter.new
        stdout, stderr = capture_io do
          formatter.engine_running(engine_double("cool_engine")) do
            formatter.write("")
          end
        end

        stdout.must_equal("")
      end
    end

    describe "#start, write, finished" do
      it "outputs a string that can be parsed as JSON" do
        issue1 = sample_issue
        issue2 = sample_issue

        formatter = JSONFormatter.new

        stdout, stderr = capture_io do
          formatter.started
          formatter.engine_running(engine_double("cool_engine")) do
            formatter.write(issue1.to_json)
            formatter.write(issue2.to_json)
          end
          formatter.finished
        end

        parsed_json = JSON.parse(stdout)
        parsed_json.must_equal([{"type"=>"issue", "check"=>"Rubocop/Style/Documentation", "description"=>"Missing top-level class documentation comment.", "categories"=>["Style"], "remediation_points"=>10, "location"=>{"path"=>"lib/cc/analyzer/config.rb", "lines"=>{"begin"=>32, "end"=>40}}, "engine_name"=>"cool_engine"}, {"type"=>"issue", "check"=>"Rubocop/Style/Documentation", "description"=>"Missing top-level class documentation comment.", "categories"=>["Style"], "remediation_points"=>10, "location"=>{"path"=>"lib/cc/analyzer/config.rb", "lines"=>{"begin"=>32, "end"=>40}}, "engine_name"=>"cool_engine"}])
      end

      it "prints a correctly formatted array of comma separated JSON issues" do
        issue1 = sample_issue
        issue2 = sample_issue

        formatter = JSONFormatter.new

        stdout, stderr = capture_io do
          formatter.started
          formatter.engine_running(engine_double("cool_engine")) do
            formatter.write(issue1.to_json)
            formatter.write(issue2.to_json)
          end
          formatter.finished
        end

        last_two_characters = stdout[stdout.length-2..stdout.length-1]

        stdout.first.must_match("[")
        last_two_characters.must_match("]\n")

        stdout.must_equal("[{\"type\":\"issue\",\"check\":\"Rubocop/Style/Documentation\",\"description\":\"Missing top-level class documentation comment.\",\"categories\":[\"Style\"],\"remediation_points\":10,\"location\":{\"path\":\"lib/cc/analyzer/config.rb\",\"lines\":{\"begin\":32,\"end\":40}},\"engine_name\":\"cool_engine\"},\n{\"type\":\"issue\",\"check\":\"Rubocop/Style/Documentation\",\"description\":\"Missing top-level class documentation comment.\",\"categories\":[\"Style\"],\"remediation_points\":10,\"location\":{\"path\":\"lib/cc/analyzer/config.rb\",\"lines\":{\"begin\":32,\"end\":40}},\"engine_name\":\"cool_engine\"}]\n")
      end
    end

    def engine_double(name)
      stub(name: name)
    end
  end
end
