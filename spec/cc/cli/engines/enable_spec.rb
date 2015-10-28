require "spec_helper"

module CC::CLI::Engines
  describe Enable do
    describe "#run" do
      before { Install.any_instance.stubs(:run) }

      describe "when the engine requested does not exist" do
        it "says engine does not exist" do
          within_temp_dir do
            create_yaml
            filesystem.exist?(".codeclimate.yml").must_equal(true)

            stdout, stderr = capture_io do
              Enable.new(args = ["the_litte_engine_that_could"]).run
            end

            stdout.must_match("Engine not found. Run 'codeclimate engines:list' for a list of valid engines.")
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

      describe "when engine has a default configuration" do
        it "it includes the config when enabling an engine" do
          within_temp_dir do
            create_yaml(Factory.create_yaml_with_no_engines)

            stdout, stderr = capture_io do
              Enable.new(args = ["duplication"]).run
            end

            content_after = File.read(".codeclimate.yml")

            stdout.must_match("Engine added")
            config = CC::Analyzer::Config.new(content_after).engine_config("duplication")
            config["config"].must_equal("languages" => %w[ruby javascript python php])
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
