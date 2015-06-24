require "spec_helper"

module CC::CLI
  describe Command do
    describe "#require_codeclimate_yml" do
      it "exits if the file doesn't exist" do
        Dir.chdir(Dir.mktmpdir) do
          _, stderr = capture_io do
            lambda { Command.new.require_codeclimate_yml }.must_raise SystemExit
          end

          stderr.must_match("No '.codeclimate.yml' file found. Run 'codeclimate init' to generate a config file.")
        end
      end
    end
  end
end
