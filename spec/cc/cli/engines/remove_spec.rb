require "spec_helper"

module CC::CLI::Engines
  describe Remove do
    include FileSystemHelpers
    include CC::Yaml::TestHelpers

    describe "#run" do
      describe "when the engine requested does not exist in Code Climate registry" do
        it "says engine does not exist" do
          within_temp_dir do
            create_codeclimate_yaml("")

            stdout, stderr = capture_io do
              Remove.new(args = ["the_litte_engine_that_could"]).run
            end

            stdout.must_match("Engine not found. Run 'codeclimate engines:list' for a list of valid engines.")
          end
        end
      end

      describe "when engine to be removed is present in .codeclimate.yml" do
        it "removes the engine and reports that it was removed" do
          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engines:
                rubocop:
                  enabled: true
            EOYAML

            stdout, _ = capture_io do
              Remove.new(args = ["rubocop"]).run
            end

            stdout.must_match("Engine removed from .codeclimate.yml.")
            expect_codeclimate_yaml do |config|
              config.engines.key?("rubocop").must_equal false
            end
          end
        end
      end
    end
  end
end
