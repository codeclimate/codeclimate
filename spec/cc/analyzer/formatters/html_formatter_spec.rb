require 'spec_helper'

module CC::Analyzer::Formatters
  describe HTMLFormatter do
    include Factory

    let(:formatter) do
      HTMLFormatter.new(CC::Analyzer::Filesystem.new(
        CC::Analyzer::MountedPath.code.container_path
      ))
    end

    describe "#finished" do
      it "outputs an HTML report" do
        engine = double(name: "cool_engine")

        stdout, _ = capture_io do
          issue = sample_issue({
            "content"=> {
              "body" => "### Sample Issue\n\n*Sample*"
            }
          })
          write_from_engine(formatter, engine, issue)
          formatter.finished
        end

        expect(stdout).to include("1 issue found in 1 files.")
        expect(stdout).to include("<a name='lib/cc/analyzer/config.rb'>lib/cc/analyzer/config.rb</a> (1 issue)")
        expect(stdout).to include("<h3>Sample Issue</h3>")
      end
    end

    def write_from_engine(formatter, engine, issue)
      formatter.engine_running(engine) do
        formatter.write(issue.to_json)
      end
    end
  end
end
