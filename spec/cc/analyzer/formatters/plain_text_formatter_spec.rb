require 'spec_helper'

module CC::Analyzer::Formatters
  describe PlainTextFormatter do
    include Factory

    let(:formatter) do
      filesystem ||= CC::Analyzer::Filesystem.new(ENV['FILESYSTEM_DIR'])
      PlainTextFormatter.new(filesystem)
    end

    describe "#write" do
      it "raises an error" do
        engine = stub(name: "engine")

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

        stdout, _ = capture_io do
          write_from_engine(formatter, engine, sample_issue)
          formatter.finished
        end

        stdout.must_match("config.rb (1 issue)")
        stdout.must_match("Missing top-level class documentation comment")
        stdout.must_match("[cool_engine]")
      end

      it "reports issue severity when info" do
        engine = stub(name: "cool_engine")

        stdout, _ = capture_io do
          write_from_engine(formatter, engine, sample_issue_with_severity("info"))
          formatter.finished
        end

        stdout.must_match("[info]")
      end

      it "reports issue severity when critical" do
        engine = stub(name: "cool_engine")

        stdout, _ = capture_io do
          write_from_engine(formatter, engine, sample_issue_with_severity("critical"))
          formatter.finished
        end

        stdout.must_match("[critical]")
      end

      it "does not report severity when normal" do
        engine = stub(name: "cool_engine")

        stdout, _ = capture_io do
          write_from_engine(formatter, engine, sample_issue_with_severity("normal"))
          formatter.finished
        end

        stdout.wont_match("[normal]")
      end
    end

    def write_from_engine(formatter, engine, issue)
      formatter.engine_running(engine) do
        formatter.write(issue.to_json)
      end
    end
  end
end
