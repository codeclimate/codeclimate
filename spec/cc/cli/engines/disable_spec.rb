require "spec_helper"

module CC::CLI::Engines
  describe Disable do
    describe "#run" do
      describe "when no .codeclimate.yml file is present" do
        it "prompts the user to generate a config using 'codeclimate init'" do
          within_temp_dir do
            filesystem.exist?(".codeclimate.yml").must_equal(false)

            stdout, stderr = capture_io do
              Disable.new(args = ["rubocop"]).run
            end

            stdout.must_match("No .codeclimate.yml file found. Run 'codeclimate init' to generate a config file.")
            filesystem.exist?(".codeclimate.yml").must_equal(false)
          end
        end
      end

      describe "when the engine requested does not exist in Code Climate registry" do
        it "says engine does not exist" do
          within_temp_dir do
            create_yaml
            filesystem.exist?(".codeclimate.yml").must_equal(true)

            stdout, stderr = capture_io do
              Disable.new(args = ["the_litte_engine_that_could"]).run
            end

            stdout.must_match("Engine not found. Run 'codeclimate engines:list for a list of valid engines.")
          end
        end
      end

      describe "when engine is present in .codeclimate.yml and already disabled" do
        it "reports that engine is already disabled" do
          within_temp_dir do
            create_yaml(Factory.yaml_without_rubocop_enabled)

            stdout, stderr = capture_io do
              Disable.new(args = ["rubocop"]).run
            end

            stdout.must_match("Engine already disabled.")
          end
        end
      end

      describe "when engine is present in .codeclimate.yml and enabled" do
        it "disables engine in yaml file" do
          within_temp_dir do
            create_yaml(Factory.yaml_with_rubocop_enabled)
            content_before = File.read(".codeclimate.yml")

            stdout, stderr = capture_io do
              Disable.new(args = ["rubocop"]).run
            end

            content_after = File.read(".codeclimate.yml")

            stdout.must_match("Engine disabled.")
            CC::Analyzer::Config.new(content_before).engine_enabled?("rubocop").must_equal(true)
            CC::Analyzer::Config.new(content_after).engine_enabled?("rubocop").must_equal(false)
          end
        end
      end
    end

    def filesystem
      @filesystem || CC::Analyzer::Filesystem.new(".")
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
