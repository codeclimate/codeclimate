require 'spec_helper'

module CC::Analyzer::Formatters
  describe PlainTextFormatter do
    include Factory

    describe "#write" do
      it "raises an error" do
        engine = stub(name: "engine")
        formatter = PlainTextFormatter.new

        runner = lambda do
          capture_io do
            write_from_engine(formatter, engine, "type" => "thing")
          end
        end

        runner.must_raise(RuntimeError, "Invalid type found: thing")
      end
    end

    describe "#finished" do
      it "outputs a breakdown" do
        engine = stub(name: "cool_engine")
        formatter = PlainTextFormatter.new

        stdout, _ = capture_io do
          write_from_engine(formatter, engine, sample_issue)
          formatter.finished
        end

        stdout.must_match("config.rb (1 issue)")
        stdout.must_match("Missing top-level class documentation comment")
        stdout.must_match("[cool_engine]")
      end
    end

    def write_from_engine(formatter, engine, issue)
      formatter.engine_running(engine) do
        formatter.write(issue.to_json)
      end
    end
  end
end
