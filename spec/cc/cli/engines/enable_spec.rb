require "spec_helper"

module CC::CLI::Engines
  describe Enable do
    include FileSystemHelpers
    include CC::Yaml::TestHelpers

    describe "#run" do
      before { Install.any_instance.stubs(:run) }

      describe "when the engine requested does not exist" do
        it "says engine does not exist" do
          within_temp_dir do
            create_codeclimate_yaml("")

            stdout, _ = capture_io do
              Enable.new(args = ["the_litte_engine_that_could"]).run
            end

            stdout.must_match("Engine not found. Run 'codeclimate engines:list' for a list of valid engines.")
          end
        end
      end

      describe "when engine is already enabled" do
        it "reports that engine is enabled, doesn't change .codeclimate.yml" do
          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engines:
                rubocop:
                  enabled: true
            EOYAML

            stdout, _ = capture_io do
              Enable.new(args = ["rubocop"]).run
            end

            stdout.must_match("Engine already enabled.")
            expect_codeclimate_yaml do |config|
              config.engines["rubocop"].enabled?.must_equal true
            end
          end
        end
      end

      describe "when engine is in registry, but not enabled" do
        it "enables engine in yaml file" do
          skip "YAML::Node#[]= explodes yay!"

          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engines:
                rubocop:
                  enabled: false
            EOYAML

            stdout, _ = capture_io do
              Enable.new(args = ["rubocop"]).run
            end

            stdout.must_match("Engine added")
            expect_codeclimate_yaml do |config|
              config.engines["rubocop"].enabled?.must_equal true
            end
          end
        end
      end
    end
  end
end
