require "spec_helper"

module CC::CLI::Engines
  describe Remove do
    describe "#run" do
      describe "when the engine requested does not exist in Code Climate registry" do
        it "says engine does not exist" do
          within_temp_dir do
            create_yaml
            expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

            stdout, stderr = capture_io do
              Remove.new(args = ["the_litte_engine_that_could"]).run
            end

            expect(stdout).to match("Engine not found. Run 'codeclimate engines:list' for a list of valid engines.")
          end
        end
      end

      describe "when engine to be removed is present in .codeclimate.yml" do
        it "reports that engine is removed" do
          within_temp_dir do
            create_yaml(Factory.yaml_with_rubocop_enabled)

            stdout, stderr = capture_io do
              Remove.new(args = ["rubocop"]).run
            end

            expect(stdout).to match("Engine removed from .codeclimate.yml.")
          end
        end

        it "removes engine from yaml file" do
          within_temp_dir do
            create_yaml(Factory.yaml_with_rubocop_enabled)

            stdout, stderr = capture_io do
              Remove.new(args = ["rubocop"]).run
            end

            content_after = File.read(".codeclimate.yml")

            expect(stdout).to match("Engine removed from .codeclimate.yml.")
            expect(CC::Analyzer::Config.new(content_after).engine_present?("rubocop")).to eq(false)
          end
        end
      end
    end

    def filesystem
      @filesystem ||= CC::Analyzer::Filesystem.new(".")
    end

    def within_temp_dir(&block)
      temp = Dir.mktmpdir

      Dir.chdir(temp) do
        yield
      end
    end

    def create_yaml(yaml_content = Factory.create_correct_yaml)
      File.write(".codeclimate.yml", yaml_content)
    end
  end
end
