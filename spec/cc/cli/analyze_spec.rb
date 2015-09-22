require "spec_helper"

module CC::CLI
  describe Analyze do
    describe "#run" do
      before { CC::Analyzer::Engine.any_instance.stubs(:run) }

      describe "when no engines are specified" do
        it "exits and reports no engines are enabled" do
          within_temp_dir do
            create_yaml(Factory.create_yaml_with_no_engines)

            _, stderr = capture_io do
              lambda { Analyze.new.run }.must_raise SystemExit
            end

            stderr.must_match("No enabled engines. Add some to your .codeclimate.yml file!")
          end
        end

        describe "when engine is not in registry" do
          it "ignores engine, without blowing up" do
            within_temp_dir do
              create_yaml(<<-EOYAML)
                engines:
                  madeup:
                    enabled: true
                  rubocop:
                    enabled: true
              EOYAML

              _, stderr = capture_io do
                Analyze.new.run
              end

              stderr.must_match("")
            end
          end
        end

        describe "when user passes engine options to command" do
          it "uses only the engines provided" do
            within_temp_dir do
              create_yaml(<<-EOYAML)
                engines:
                  rubocop:
                    enabled: true
              EOYAML

              args = ["-e", "eslint"]

              analyze = Analyze.new(args)
              qualified_config = analyze.send(:config)

              qualified_config.engines.must_equal("eslint" => { "enabled" => true })
            end
          end
        end

        describe "when user passes path args to command" do
          it "captures the paths provided as path_options" do
            within_temp_dir do
              create_yaml(<<-EOYAML)
                engines:
                  rubocop:
                    enabled: true
                  eslint:
                    enabled: true
              EOYAML

              args = ["-e", "eslint", "foo.rb"]
              paths = ["foo.rb"]

              analyze = Analyze.new(args)

              analyze.send(:path_options).must_equal(paths)
            end
          end
        end

        describe "when user passes path args to command" do
          it "passes the paths provided" do
            within_temp_dir do
              create_yaml(<<-EOYAML)
                engines:
                  rubocop:
                    enabled: true
                  eslint:
                    enabled: true
              EOYAML

              args = ["-e", "eslint", "foo.rb"]
              paths = ["foo.rb"]

              analyze = Analyze.new(args)
              engines_runner = stub(run: "peace")

              CC::Analyzer::EnginesRunner.expects(:new).with(anything, anything, anything, anything, paths).returns(engines_runner)

              analyze.run
            end
          end
        end
      end
    end

    def within_temp_dir(&block)
      Dir.chdir(Dir.mktmpdir, &block)
    end

    def create_yaml(yaml_content = Factory.create_correct_yaml)
      File.write(".codeclimate.yml", yaml_content)
    end
  end
end
