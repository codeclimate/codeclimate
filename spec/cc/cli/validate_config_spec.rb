require "spec_helper"

module CC::CLI
  describe ValidateConfig do
    describe "#run" do
      describe "when a .codeclimate.yml file is present in working directory" do
        it "analyzes the .codeclimate.yml file without altering it" do
          within_temp_dir do
            expect(filesystem.exist?(".codeclimate.yml")).to eq(false)

            yaml_content_before = "This is a test yaml!"
            File.write(".codeclimate.yml", yaml_content_before)

            expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

            capture_io do
              validate_config = ValidateConfig.new
              validate_config.run
            end

            expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

            content_after = File.read(".codeclimate.yml")

            expect(content_after).to eq(yaml_content_before)
          end
        end

        describe "when there are errors present" do
          it "reports that an error was found" do
            within_temp_dir do
              yaml_content = Factory.create_yaml_with_errors
              File.write(".codeclimate.yml", yaml_content)

              stdout, stderr = capture_io do
                ValidateConfig.new.run
              end

              expect(stdout).to match("ERROR")
            end
          end
        end

        describe "when there are warnings present" do
          it "reports that a warning was found" do
            within_temp_dir do
              yaml_content = Factory.create_yaml_with_warning
              File.open(".codeclimate.yml", "w") do |f|
                f.write(yaml_content)
              end

              stdout, stderr = capture_io do
                ValidateConfig.new.run
              end

              expect(stdout).to match("WARNING:")
            end
          end
        end

        describe "when there are nested warnings present" do
          it "reports that a warning was found in the parent item" do
            within_temp_dir do
              yaml_content = Factory.create_yaml_with_nested_warning
              File.write(".codeclimate.yml", yaml_content)

              stdout, stderr = capture_io do
                ValidateConfig.new.run
              end

              expect(stdout).to match("ERROR: invalid \"engines\" section")
            end
          end
        end

        describe "when there are both regular and nested warnings present" do
          it "reports both kinds of warnings" do
            within_temp_dir do
              yaml_content = Factory.create_yaml_with_nested_and_unnested_warnings
              File.write(".codeclimate.yml", yaml_content)

              stdout, stderr = capture_io do
                ValidateConfig.new.run
              end

              expect(stdout).to match("ERROR: invalid \"engines\" section")
            end
          end
        end

        describe "when the present yaml is valid" do
          it "reports copy looks great" do
            within_temp_dir do
              yaml_content = Factory.create_correct_yaml
              File.write(".codeclimate.yml", yaml_content)

              stdout, stderr = capture_io do
                ValidateConfig.new.run
              end

              expect(stdout).to match("No errors or warnings found in .codeclimate.yml file.")
            end
          end
        end

        describe "when there are invalid engines" do
          it "reports that those engines are invalid" do
            within_temp_dir do
              yaml_content = <<-YAML
                engines:
                  rubocop:
                    enabled: true
                  madeup:
                    enabled: true
                ratings:
                  paths:
                  - "**/*.rb"
                  - "**/*.js"
              YAML

              File.write(".codeclimate.yml", yaml_content)

              stdout, stderr = capture_io do
                ValidateConfig.new.run
              end

              expect(stdout).to include("WARNING: unknown engine <madeup>")
            end
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
  end
end
