require "spec_helper"

module CC
  module Analyzer
    module Formatters
      RSpec.describe HTMLFormatter do # rubocop: disable Metrics/BlockLength
        let(:formatter) do
          HTMLFormatter.new(
            CC::Analyzer::Filesystem.new(
              CC::Analyzer::MountedPath.code.container_path,
            ),
          )
        end

        describe "#finished" do
          let(:engine) { double(name: "cool_engine") }

          it "outputs an HTML report" do
            stdout, = capture_io do
              issue = sample_issue(
                "content" => {
                  "body" => "### Sample Issue\n\n*Sample*",
                },
              )
              write_from_engine(formatter, engine, issue)
              formatter.finished
            end

            expect(stdout).to include("spec/fixtures/source2.rb")
            expect(stdout).to include("<h3>Sample Issue</h3>")
            expect(stdout).to include("cool_engine")
          end

          it "outputs an HTML report with other_locations" do
            stdout, = capture_io do
              issue = sample_issue(
                "other_locations" => [{
                  "path" => "lib/cc/analyzer/engine.rb",
                  "positions" => {
                    "begin" => {
                      "line" => 1,
                      "column" => 2,
                    },
                    "end" => {
                      "line" => 3,
                      "column" => 4,
                    },
                  },
                }],
              )
              write_from_engine(formatter, engine, issue)
              formatter.finished
            end

            expect(stdout).to include("<summary>Other instances</summary>")
            expect(stdout).to include("lib/cc/analyzer/engine.rb")
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
