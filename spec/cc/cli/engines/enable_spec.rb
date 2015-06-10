require "spec_helper"

module CC::CLI::Engines
  describe Enable do
    describe "#run" do
      describe "when no .codeclimate.yml file is present" do
        it "prompts the user to generate a config using 'codeclimate init'" do
          within_temp_dir do
            filesystem.exist?(".codeclimate.yml").must_equal(false)

            stdout, stderr = capture_io do
              Enable.new(args = ["rubocop"]).run
            end

            stdout.must_match("No .codeclimate.yml file found. Run 'codeclimate init' to generate a config file.")
            filesystem.exist?(".codeclimate.yml").must_equal(false)
          end
        end
      end
      describe "when the engine requested does not exist" do
        it "says engine does not exist" do
          within_temp_dir do
            create_yaml
            filesystem.exist?(".codeclimate.yml").must_equal(true)

            stdout, stderr = capture_io do
              Enable.new(args = ["the_litte_engine_that_could"]).run
            end

            stdout.must_match("Engine not found. Run 'codeclimate engines:list for a list of valid engines.")
          end
        end
      end
      describe "when engine is already enabled" do
        it "reports that engine is enabled, doesn't change .codeclimate.yml" do
          within_temp_dir do
            create_yaml(Factory.yaml_with_rubocop_enabled)

            stdout, stderr = capture_io do
              Enable.new(args = ["rubocop"]).run
            end

            content_after = File.read(".codeclimate.yml")

            stdout.must_match("Engine already enabled.")
            content_after.must_equal(Factory.yaml_with_rubocop_enabled)
          end
        end
      end
      describe "when engine is in registry, but not enabled" do
        it "enables engine in yaml file" do
          within_temp_dir do
            create_yaml(Factory.yaml_without_rubocop_enabled)

            stdout, stderr = capture_io do
              Enable.new(args = ["rubocop"]).run
            end

            content_after = File.read(".codeclimate.yml")

            stdout.must_match("Engine added")
            CC::Analyzer::Config.new(content_after).engine_enabled?("rubocop").must_equal(true)
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
      File.open(".codeclimate.yml", "w") do |f|
        f.write(yaml_content)
      end
    end
  end
end
