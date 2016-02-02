require "spec_helper"

module CC::CLI
  describe Analyze do
    describe "#run" do
      before do
        allow_any_instance_of(CC::Analyzer::Engine).to receive(:run)
      end

      describe "when no engines are specified" do
        it "exits and reports no engines are enabled" do
          within_temp_dir do
            create_yaml(Factory.create_yaml_with_no_engines)

            _, stderr = capture_io do
              expect { Analyze.new.run }.to raise_error SystemExit
            end

            expect(stderr).to match("No enabled engines. Add some to your .codeclimate.yml file!")
          end
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

            expect(stderr).to match("")
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

            expect(qualified_config.engines).to eq("eslint" => { "enabled" => true })
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

            expect(analyze.send(:path_options)).to eq(paths)
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
            engines_runner = double(run: "peace")

            expect(CC::Analyzer::EnginesRunner).to receive(:new).with(anything, anything, anything, anything, paths).and_return(engines_runner)

            analyze.run
          end
        end
      end

      describe "when a formatter argument is passed" do
        it "instantiates the correct formatter with a proper Filesystem argument" do
          expect(CC::Analyzer::Formatters::JSONFormatter).to receive(:new).
            with(kind_of(CC::Analyzer::Filesystem))

          Analyze.new(%w[-f json])
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
