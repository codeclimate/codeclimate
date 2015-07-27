require "spec_helper"

module CC::CLI
  describe Analyze do
    include FileSystemHelpers
    include CC::Yaml::TestHelpers

    describe "#run" do
      before { CC::Analyzer::Engine.any_instance.stubs(:run) }

      describe "when no engines are specified" do
        it "exits and reports no engines are enabled" do
          within_temp_dir do
            # TODO: is entirely empty valid?
            #create_codeclimate_yaml("")
            create_codeclimate_yaml(<<-EOYAML)
              engines:
            EOYAML

            _, stderr = capture_io do
              lambda { Analyze.new.run }.must_raise SystemExit
            end

            stderr.must_match("No enabled engines. Add some to your .codeclimate.yml file!")
          end
        end

        describe "when engine is not in registry" do
          it "reports that no engines are enabled" do
            within_temp_dir do
              create_codeclimate_yaml(<<-EOYAML)
                engines:
                  madeup:
                    enabled: true
                  rubocop:
                    enabled: true
              EOYAML

              _, stderr = capture_io do
                lambda { Analyze.new(args = []).run }.must_raise SystemExit
              end

              stderr.must_match("unknown engine name: madeup")
            end
          end
        end
      end
    end
  end
end
