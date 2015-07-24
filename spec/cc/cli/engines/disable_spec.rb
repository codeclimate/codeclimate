require "spec_helper"

module CC::CLI::Engines
  describe Disable do
    include FileSystemHelpers
    include CC::Yaml::TestHelpers

    describe "#run" do
      describe "when the engine requested does not exist in Code Climate registry" do
        it "says engine does not exist" do
          within_temp_dir do
            create_codeclimate_yaml("")

            stdout, _ = capture_io do
              Disable.new(args = ["the_litte_engine_that_could"]).run
            end

            stdout.must_match("Engine not found. Run 'codeclimate engines:list' for a list of valid engines.")
          end
        end
      end

      describe "when engine is present in .codeclimate.yml and already disabled" do
        it "reports that engine is already disabled" do
          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engines:
                rubocop:
                  enabled: false
            EOYAML

            stdout, _ = capture_io do
              Disable.new(args = ["rubocop"]).run
            end

            stdout.must_match("Engine already disabled.")
          end
        end
      end

      describe "when engine is present in .codeclimate.yml and enabled" do
        it "disables engine in yaml file" do
          skip "YAML::Node#[]= explodes yay!"

          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engines:
                rubocop:
                  enabled: true
            EOYAML

            stdout, _ = capture_io do
              Disable.new(args = ["rubocop"]).run
            end

            stdout.must_match("Engine disabled.")
            expect_codeclimate_yaml do |config|
              config.engines["rubocop"].enabled?.must_equal false
            end
          end
        end
      end
    end
  end
end
