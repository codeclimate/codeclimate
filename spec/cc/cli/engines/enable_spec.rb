require "spec_helper"

module CC::CLI::Engines
  describe Enable do
    describe "#run" do
      before do
        allow_any_instance_of(Install).to receive(:run)
      end

      describe "when the engine requested does not exist" do
        it "says engine does not exist" do
          within_temp_dir do
            create_yaml
            expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

            stdout, stderr = capture_io do
              Enable.new(args = ["the_litte_engine_that_could"]).run
            end

            expect(stdout).to match("Engine not found. Run 'codeclimate engines:list' for a list of valid engines.")
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

            expect(stdout).to match("Engine already enabled.")
            expect(content_after).to eq(Factory.yaml_with_rubocop_enabled)
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

            expect(stdout).to match("Engine added")
            expect(CC::Analyzer::Config.new(content_after).engine_enabled?("rubocop")).to eq(true)
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

            expect(stdout).to match("Engine added")
            config = CC::Analyzer::Config.new(content_after).engine_config("duplication")
            expect(config["config"]).to eq("languages" => %w[ruby javascript python php])
          end
        end
      end

      describe "when engine has no default configuration" do
        it "it omits the config key entirely" do
          within_temp_dir do
            create_yaml(Factory.create_yaml_with_no_engines)

            stdout, stderr = capture_io do
              Enable.new(args = ["coffeelint"]).run
            end

            content_after = File.read(".codeclimate.yml")

            config = CC::Analyzer::Config.new(content_after).engine_config("coffeelint")

            expect(config).to eq({"enabled" => true})
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
