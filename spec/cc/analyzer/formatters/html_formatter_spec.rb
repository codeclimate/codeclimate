require "spec_helper"

module CC
  module Analyzer
    module Formatters
      RSpec.describe HTMLFormatter do # rubocop: disable Metrics/BlockLength
        include Factory

        let(:formatter) do
          HTMLFormatter.new(
            CC::Analyzer::Filesystem.new(
              CC::Analyzer::MountedPath.code.container_path,
            ),
          )
        end

        describe "#finished" do
          it "outputs an HTML report" do
            engine = double(name: "cool_engine")

            stdout, = capture_io do
              issue = sample_issue(
                "content" => {
                  "body" => "### Sample Issue\n\n*Sample*",
                },
              )
              write_from_engine(formatter, engine, issue)
              formatter.finished
            end

            expect(stdout).to include("lib/cc/analyzer/config.rb")
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
  end
end
