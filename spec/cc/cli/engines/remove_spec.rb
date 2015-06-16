require "spec_helper"

module CC::CLI::Engines
  describe Remove do
    describe "#run" do
      describe "when the engine requested does not exist in Code Climate registry" do
        it "says engine does not exist" do
          within_temp_dir do
            create_yaml
            filesystem.exist?(".codeclimate.yml").must_equal(true)

            stdout, stderr = capture_io do
              Remove.new(args = ["the_litte_engine_that_could"]).run
            end

            stdout.must_match("Engine not found. Run 'codeclimate engines:list for a list of valid engines.")
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

            stdout.must_match("Engine removed from .codeclimate.yml.")
          end
        end

        it "removes engine from yaml file" do
          within_temp_dir do
            create_yaml(Factory.yaml_with_rubocop_enabled)

            stdout, stderr = capture_io do
              Remove.new(args = ["rubocop"]).run
            end

            content_after = File.read(".codeclimate.yml")

            stdout.must_match("Engine removed from .codeclimate.yml.")
            CC::Analyzer::Config.new(content_after).engine_present?("rubocop").must_equal(false)
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
