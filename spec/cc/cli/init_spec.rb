require "spec_helper"
require "cc/yaml"

module CC::CLI
  describe Init do
    describe "#run" do
      describe "when no .codeclimate.yml file is present in working directory" do
        it "creates a correct .codeclimate.yml file and reports successful creation" do
          within_temp_dir do
            filesystem.exist?(".codeclimate.yml").must_equal(false)
            File.write("cool.rb", "class Cool; end")
            FileUtils.mkdir_p("js")
            File.write("js/foo.js", "function() {}");
            FileUtils.mkdir_p("stylesheets")
            File.write("stylesheets/main.css", ".main {}")
            FileUtils.mkdir_p("vendor/jquery")
            File.write("vendor/foo.css", ".main {}")
            File.write("vendor/jquery/jquery.css", ".main {}")
            FileUtils.mkdir_p("spec/models")
            File.write("spec/spec_helper.rb", ".main {}")
            File.write("spec/models/foo.rb", ".main {}")
            FileUtils.mkdir_p("config")
            File.write("config/foo.rb", ".main {}")

            stdout, stderr = capture_io do
              init = Init.new
              init.run
            end

            new_content = File.read(".codeclimate.yml")

            stdout.must_match "Config file .codeclimate.yml successfully generated."
            filesystem.exist?(".codeclimate.yml").must_equal(true)

            YAML.safe_load(new_content).must_equal({
              "engines" => {
                "rubocop" => { "enabled"=>true },
                "eslint" => { "enabled"=>true },
                "csslint" => { "enabled"=>true },
                "duplication" => { "enabled"=>true, "config"=>{"languages"=>["ruby"] }},
              },
              "ratings" => { "paths" => ["**.rb", "**.js", "**.jsx", "**.css"] },
              "exclude_paths" => ["config/**/*", "spec/**/*", "vendor/**/*"],
            })

            CC::Yaml.parse(new_content).errors.must_be_empty
          end
        end

        describe 'when default config for engine is available' do
          describe 'when no config file for this engine exists in working directory' do
            it 'creates .engine.yml with default config' do
              within_temp_dir do
                File.write('foo.rb', 'class Foo; end')

                stdout, stderr = capture_io do
                  init = Init.new
                  init.run
                end

                new_content = File.read('.rubocop.yml')

                stdout.must_match 'Config file .rubocop.yml successfully generated.'
                filesystem.exist?('.rubocop.yml').must_equal(true)
                YAML.safe_load(new_content).keys.must_include('AllCops')
              end
            end
          end

          describe 'when config file for this engine already exists in working directory' do
            it 'skips engine config file generation' do
              within_temp_dir do
                File.write('foo.rb', 'class Foo; end')

                content_before = 'test content'
                File.write('.rubocop.yml', content_before)

                stdout, stderr = capture_io do
                  init = Init.new
                  init.run
                end

                content_after = File.read('.rubocop.yml')

                stdout.must_match 'Skipping generating .rubocop.yml file (already exists).'
                filesystem.exist?('.rubocop.yml').must_equal(true)
                content_after.must_equal(content_before)
              end
            end
          end
        end
      end

      describe "when a .codeclimate.yml file is already present in working directory" do
        it "does not create a new file or overwrite the old" do
          within_temp_dir do
            filesystem.exist?(".codeclimate.yml").must_equal(false)

            yaml_content_before = "This is a test yaml!"
            File.write(".codeclimate.yml", yaml_content_before)

            filesystem.exist?(".codeclimate.yml").must_equal(true)

            capture_io do
              Init.new.run
            end

            content_after = File.read(".codeclimate.yml")

            filesystem.exist?(".codeclimate.yml").must_equal(true)
            content_after.must_equal(yaml_content_before)
          end
        end

        it "reports that there is a .codeclimate.yml file already present" do
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
