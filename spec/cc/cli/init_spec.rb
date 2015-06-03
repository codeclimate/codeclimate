require "spec_helper"
require "cc/cli"

module CC::CLI
  describe Init do
    describe "#run" do
      describe "when no .codeclimate.yml file is present in working directory" do
        it "creates a correct .codeclimate.yml file" do
          temp = Dir.mktmpdir
          
          Dir.chdir(temp) do
            filesystem = CC::Analyzer::Filesystem.new(".")
            
            filesystem.exist?(".codeclimate.yml").must_equal(false)

            init = Init.new
            init.run

            filesystem.exist?(".codeclimate.yml").must_equal(true)

            new_content = File.read(".codeclimate.yml")

            new_content.must_equal(Init::TEMPLATE_CODECLIMATE_YAML)
          end
        end 
      end

      describe "when a .codeclimate.yml file is already present in working directory" do
        it "does not create a new file or overwrite the old" do
          temp = Dir.mktmpdir

          Dir.chdir(temp) do
            filesystem = CC::Analyzer::Filesystem.new(".")

            filesystem.exist?(".codeclimate.yml").must_equal(false)


            yaml_content_before = "This is a test yaml!"
            File.open(".codeclimate.yml", "w") do |f|
              f.write(yaml_content_before)
            end

            filesystem.exist?(".codeclimate.yml").must_equal(true)

            init = Init.new
            init.run

            filesystem.exist?(".codeclimate.yml").must_equal(true)

            content_after = File.read(".codeclimate.yml")

            content_after.must_equal(yaml_content_before)
          end
        end
      end
    end
  end
end


