require "spec_helper"

module CC::CLI
  describe ValidateConfig do
    include FileSystemHelpers
    include CC::Yaml::TestHelpers

    describe "#run" do
      describe "when there are errors present" do
        it "reports that an error was found" do
          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engkxhfgkxfhg: sdoufhsfogh: -
              0-
              fgkjfhgkdjfg;h:;
                sligj:
              oi i ;
            EOYAML

            stdout, _ = capture_io do
              ValidateConfig.new.run
            end

            stdout.must_match("ERROR")
          end
        end
      end

      describe "when there are warnings present" do
        it "reports that a warning was found" do
          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engines:
              unknown_key:
            EOYAML

            stdout, _ = capture_io do
              ValidateConfig.new.run
            end

            stdout.must_match("WARNING:")
          end
        end
      end

      describe "when there are nested warnings present" do
        it "reports that a warning was found in the parent item" do
          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engines:
                rubocop:
            EOYAML

            stdout, _ = capture_io do
              ValidateConfig.new.run
            end

            stdout.must_match("WARNING in")
          end
        end
      end

      describe "when there are both regular and nested warnings present" do
        it "reports both kinds of warnings" do
          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engines:
                rubocop:
                  enabled: true
                jshint:
                  not_enabled
              strange_key:
            EOYAML

            stdout, _ = capture_io do
              ValidateConfig.new.run
            end

            stdout.must_match("WARNING in")
            stdout.must_match("WARNING:")
          end
        end
      end

      describe "when the present yaml is valid" do
        it "reports copy looks great" do
          within_temp_dir do
            create_codeclimate_yaml(<<-EOYAML)
              engines:
                rubocop:
                  enabled: true
            EOYAML

            stdout, _ = capture_io do
              ValidateConfig.new.run
            end

            stdout.must_match("No errors or warnings found in .codeclimate.yml file.")
          end
        end
      end
    end
  end
end
