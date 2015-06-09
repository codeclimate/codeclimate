require "spec_helper"
require "cc/cli"

module CC::CLI
  describe Init do
    describe "#run" do
      describe "when no .codeclimate.yml file is present in working directory" do
        it "creates a correct .codeclimate.yml file and reports successful creation" do
          within_temp_dir do
            filesystem.exist?(".codeclimate.yml").must_equal(false)

            stdout, stderr = capture_io do
              init = Init.new
              init.run
            end

            new_content = File.read(".codeclimate.yml")

            stdout.must_match "Config file .codeclimate.yml successfully generated."
            filesystem.exist?(".codeclimate.yml").must_equal(true)
            new_content.must_equal(Init::TEMPLATE_CODECLIMATE_YAML)
          end
        end
      end

      describe "when a .codeclimate.yml file is already present in working directory" do
        it "does not create a new file or overwrite the old" do
          within_temp_dir do
            filesystem.exist?(".codeclimate.yml").must_equal(false)

            yaml_content_before = "This is a test yaml!"
            File.open(".codeclimate.yml", "w") do |f|
              f.write(yaml_content_before)
            end

            filesystem.exist?(".codeclimate.yml").must_equal(true)

            capture_io do
              Init.new.run
            end

            content_after = File.read(".codeclimate.yml")

            filesystem.exist?(".codeclimate.yml").must_equal(true)
            content_after.must_equal(yaml_content_before)
          end
        end

        it "reports that there is a .codecliamte.yml file already present" do
          within_temp_dir do
            filesystem.exist?(".codeclimate.yml").must_equal(false)

            File.new(".codeclimate.yml", "w")

            filesystem.exist?(".codeclimate.yml").must_equal(true)

            stdout, stderr = capture_io do
              Init.new.run
            end

            stdout.must_match("Config file .codeclimate.yml already present.")
          end
        end
      end
    end

    def filesystem
      @filesystem || CC::Analyzer::Filesystem.new(".")
    end

    def within_temp_dir(&block)
      temp = Dir.mktmpdir

      Dir.chdir(temp) do
        yield
      end
    end
  end
end


