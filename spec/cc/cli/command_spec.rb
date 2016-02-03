require "spec_helper"

module CC::CLI
  describe Command do
    describe "#require_codeclimate_yml" do
      it "exits if the file doesn't exist" do
        Dir.chdir(Dir.mktmpdir) do
          _, stderr = capture_io do
            expect { Command.new.require_codeclimate_yml }.to raise_error SystemExit
          end

          expect(stderr).to match("No '.codeclimate.yml' file found. Run 'codeclimate init' to generate a config file.")
        end
      end
    end
  end
end
