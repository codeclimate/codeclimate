require "spec_helper"

module CC::CLI
  describe Analyze do
    describe "#initialize" do
      it "sets dev mode for --dev" do
        instance = Analyze.new(["--dev"])

        instance.dev_mode?.must_equal true
      end

      it "sets dev mode with formatters defined" do
        instance = Analyze.new(%w[-f json --dev])

        instance.dev_mode?.must_equal true
      end
    end

    describe "#run" do
      before { CC::Analyzer::Engine.any_instance.stubs(:run) }

      describe "when no engines are specified" do
        it "exits and reports no engines are enabled" do
          within_temp_dir do
            create_yaml(Factory.create_yaml_with_no_engines)

            stdout, stderr = capture_io do
              lambda { Analyze.new(args = []).run }.must_raise SystemExit
            end

            stderr.must_match("No engines enabled. Add some to your .codeclimate.yml file!")
          end
        end

        describe "when engine is not in registry" do
          it "reports that no engines are enabled" do
            within_temp_dir do
              create_yaml
              stub_config(
                engine_names: ["madeup", "rubocop"],
                engine_config: {},
                exclude_paths: {}
              )

              stdout, stderr = capture_io do
                lambda { Analyze.new(args = []).run }.must_raise SystemExit
              end

              stderr.must_match("unknown engine name: madeup")
            end
          end
        end
      end
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

    def stub_config(stubs)
      config = stub(stubs)
      CC::Analyzer::Config.stubs(:new).returns(config)
    end
  end
end
