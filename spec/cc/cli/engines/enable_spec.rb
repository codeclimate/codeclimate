require "spec_helper"

module CC::CLI::Engines
  describe Enable do
    describe "#run" do
      it "lists all engines in the config" do
        stdout, stderr = capture_io do
          Enable.new.run("rubocop")
        end

        engines = YAML.safe_load_file("config/engines.yml")
      end
    end
  end
end
