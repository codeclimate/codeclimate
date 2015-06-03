require "spec_helper"
require "cc/cli"

module CC::CLI
  describe Init do
    describe "#run" do
      context "when no .codeclimate.yml file is present in user's repository" do
        it "creates a .codeclimate.yml file" do
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

      context "when a .codeclimate.yml file is already present in repository" do
        it "does not create a new file" do
          temp = Dir.mktmpdir

          Dir.chdir(temp) do
            filesystem = CC::Analyzer::Filesystem.new(".")
            
            expect(filesystem.exist?(".codeclimate.yml")).to eq(false)


            existing_yml_text = "This is a test yaml!"
            File.open(".codeclimate.yml", "w") do |f|
              f.write(existing_yml_text)
            end

            expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

            init = Init.new
            init.run

            expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

            post_run_yml_content = File.read(".codeclimate.yml")

            expect(post_run_yml_content).to eq(existing_yml_text)
          end
        end
      end
    end
  end
end


