require 'spec_helper'

module CC::Analyzer::Formatters
  describe PlainTextFormatter do
    describe "#write" do
      it "raises an error" do
        formatter = PlainTextFormatter.new(Object.new)
        data = {"type" => "thing"}.to_json

        lambda { formatter.write(data) }.must_raise(RuntimeError, "Invalid type found: thing")
      end
    end

    describe "#finished" do
      it "outputs a breakdown" do
        issue = Factory.sample_issue
        formatter = PlainTextFormatter.new(::CC::Analyzer::Filesystem.new("."))

        stdout, stderr = capture_io do
          formatter.engine_running(OpenStruct.new(name: "cool_engine")) do
            formatter.write(issue.to_json)
          end

          formatter.finished
        end

        stdout.must_match("config.rb (1 issue)")
        stdout.must_match("Missing top-level class documentation comment")
        stdout.must_match("[cool_engine]")
      end
    end
  end
end
