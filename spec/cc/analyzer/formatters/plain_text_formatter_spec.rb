require 'spec_helper'

module CC::Analyzer::Formatters
  describe PlainTextFormatter do
    include Factory

    let(:formatter) do
      filesystem ||= CC::Analyzer::Filesystem.new(
        CC::Analyzer::MountedPath.code.container_path
      )
      PlainTextFormatter.new(filesystem)
    end

    describe "#write" do
      it "raises an error" do
        engine = double(name: "engine")

        expect do
          capture_io do
            write_from_engine(formatter, engine, "type" => "thing")
          end
        end.to raise_error(
          RuntimeError, "Invalid type found: thing"
        )
      end
    end

    describe "#finished" do
      it "outputs a breakdown" do
        engine = double(name: "cool_engine")

        stdout, _ = capture_io do
          write_from_engine(formatter, engine, sample_issue)
          formatter.finished
        end

        expect(stdout).to include("config.rb (1 issue)")
        expect(stdout).to include("Missing top-level class documentation comment")
        expect(stdout).to include("[cool_engine]")
      end
    end

    def write_from_engine(formatter, engine, issue)
      formatter.engine_running(engine) do
        formatter.write(issue.to_json)
      end
    end
  end
end
