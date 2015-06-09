require "spec_helper"

module CC::CLI::Engines
  describe List do
    describe "#run" do
      it "lists all engines in the config" do
        stdout, stderr = capture_io do
          List.new.run
        end

        engines = YAML.safe_load_file("config/engines.yml")

        engines.each do |name, engine|
          stdout.must_match(name)
        end
      end
    end
  end
end
