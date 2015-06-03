require "spec_helper"
require "cc/cli"

module CC::CLI
  describe Init do
    describe "#run" do
      context "when no .codeclimate.yml file is present in working directory" do
        it "creates a correct .codeclimate.yml file" do
          temp = Dir.mktmpdir
          
          Dir.chdir(temp) do
            filesystem = CC::Analyzer::Filesystem.new(".")
            
            expect(filesystem.exist?(".codeclimate.yml")).to eq(false)

            init = Init.new
            init.run

            expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

            new_content = File.read(".codeclimate.yml")

            expect(new_content).to eq(Init::TEMPLATE_CODECLIMATE_YAML)
          end
        end 
      end

      context "when a .codeclimate.yml file is already present in working directory" do
        it "does not create a new file or overwrite the old" do
          temp = Dir.mktmpdir

          Dir.chdir(temp) do
            filesystem = CC::Analyzer::Filesystem.new(".")

            expect(filesystem.exist?(".codeclimate.yml")).to eq(false)


            yaml_content_before = "This is a test yaml!"
            File.open(".codeclimate.yml", "w") do |f|
              f.write(yaml_content_before)
            end

            expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

            init = Init.new
            init.run

            expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

            content_after = File.read(".codeclimate.yml")

            expect(content_after).to eq(yaml_content_before)
          end
        end
      end
    end
  end
end


