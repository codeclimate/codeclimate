require 'spec_helper'

module CC::Analyzer::Formatters
  describe JSONFormatter do
    let(:formatter) do
      filesystem ||= CC::Analyzer::Filesystem.new(
        CC::Analyzer::MountedPath.code.container_path
      )
      JSONFormatter.new(filesystem)
    end

    describe "#start, write, finished" do
      it "outputs a string that can be parsed as JSON" do
        issue1 = sample_issue
        issue2 = sample_issue

        stdout, stderr = capture_io do
          formatter.started
          formatter.engine_running(engine_double("cool_engine")) do
            formatter.write(issue1.to_json)
            formatter.write(issue2.to_json)
          end
          formatter.finished
        end

        parsed_json = JSON.parse(stdout)
        expect(parsed_json).to eq([{"type"=>"issue", "check_name"=>"Rubocop/Style/Documentation", "description"=>"Missing top-level class documentation comment.", "categories"=>["Style"], "remediation_points"=>10, "location"=>{"path"=>"spec/fixtures/source2.rb", "lines"=>{"begin"=>2, "end"=>9}}, "engine_name"=>"cool_engine"}, {"type"=>"issue", "check_name"=>"Rubocop/Style/Documentation", "description"=>"Missing top-level class documentation comment.", "categories"=>["Style"], "remediation_points"=>10, "location"=>{"path"=>"spec/fixtures/source2.rb", "lines"=>{"begin"=>2, "end"=>9}}, "engine_name"=>"cool_engine"}])
      end

      it "prints a correctly formatted array of comma separated JSON issues" do
        issue1 = sample_issue
        issue2 = sample_issue

        stdout, stderr = capture_io do
          formatter.started
          formatter.engine_running(engine_double("cool_engine")) do
            formatter.write(issue1.to_json)
            formatter.write(issue2.to_json)
          end
          formatter.finished
        end

        last_two_characters = stdout[stdout.length-2..stdout.length-1]

        expect(stdout.first).to match("[")
        expect(last_two_characters).to match("]\n")

        expect(stdout).to eq("[{\"type\":\"issue\",\"check_name\":\"Rubocop/Style/Documentation\",\"description\":\"Missing top-level class documentation comment.\",\"categories\":[\"Style\"],\"remediation_points\":10,\"location\":{\"path\":\"spec/fixtures/source2.rb\",\"lines\":{\"begin\":2,\"end\":9}},\"engine_name\":\"cool_engine\"},\n{\"type\":\"issue\",\"check_name\":\"Rubocop/Style/Documentation\",\"description\":\"Missing top-level class documentation comment.\",\"categories\":[\"Style\"],\"remediation_points\":10,\"location\":{\"path\":\"spec/fixtures/source2.rb\",\"lines\":{\"begin\":2,\"end\":9}},\"engine_name\":\"cool_engine\"}]\n")
      end
    end

    it "prints metrics" do
        issue = sample_issue
        measurement = { type: "measurement", name: "foo", value: 42 }

        stdout, stderr = capture_io do
          formatter.started
          formatter.engine_running(engine_double("cool_engine")) do
            formatter.write(issue.to_json)
            formatter.write(measurement.to_json)
          end
          formatter.finished
        end

        last_two_characters = stdout[stdout.length-2..stdout.length-1]

        expect(stdout.first).to match("[")
        expect(last_two_characters).to match("]\n")

        expect(stdout).to eq("[{\"type\":\"issue\",\"check_name\":\"Rubocop/Style/Documentation\",\"description\":\"Missing top-level class documentation comment.\",\"categories\":[\"Style\"],\"remediation_points\":10,\"location\":{\"path\":\"spec/fixtures/source2.rb\",\"lines\":{\"begin\":2,\"end\":9}},\"engine_name\":\"cool_engine\"},\n{\"type\":\"measurement\",\"name\":\"foo\",\"value\":42,\"engine_name\":\"cool_engine\"}]\n")
    end

    def engine_double(name)
      double(name: name)
    end
  end
end
