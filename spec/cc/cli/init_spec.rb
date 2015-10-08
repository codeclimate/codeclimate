require "spec_helper"
require "cc/yaml"

module CC::CLI
  describe Init do
    include Factory
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "#run" do
      describe "when no .codeclimate.yml file is present in working directory" do
        it "creates a correct .codeclimate.yml file and reports successful creation" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)
          write_fixture_source_files

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
              "duplication" => {
                "enabled" => true,
                "config" => { "languages" => ["ruby"] }
              }
            },
            "ratings" => { "paths" => ["**.rb", "**.js", "**.jsx", "**.css"] },
            "exclude_paths" => ["config/**/*", "spec/**/*", "vendor/**/*"],
          })

          CC::Yaml.parse(new_content).errors.must_be_empty
        end

        describe 'when default config for engine is available' do
          describe 'when no config file for this engine exists in working directory' do
            it 'creates .engine.yml with default config' do
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

          describe 'when config file for this engine already exists in working directory' do
            it 'skips engine config file generation' do
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

      describe "when a platform .codeclimate.yml file is already present in working directory" do
        it "does not create a new file or overwrite the old" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)

          yaml_content_before = "---\nlanguages:\n  Ruby: true\n"
          File.write(".codeclimate.yml", yaml_content_before)

          filesystem.exist?(".codeclimate.yml").must_equal(true)

          capture_io do
            Init.new.run
          end

          content_after = File.read(".codeclimate.yml")

          filesystem.exist?(".codeclimate.yml").must_equal(true)
          content_after.must_equal(yaml_content_before)
        end

        it "reports that there is a .codeclimate.yml file already present" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)

          File.new(".codeclimate.yml", "w")

          filesystem.exist?(".codeclimate.yml").must_equal(true)

          stdout, stderr = capture_io do
            Init.new.run
          end

          stdout.must_match("Config file .codeclimate.yml already present.")
        end
      end

      describe "when --upgrade flag is on" do
        it "refuses to upgrade a platform config" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)

          yaml_content_before = yaml_with_rubocop_enabled
          File.write(".codeclimate.yml", yaml_content_before)

          filesystem.exist?(".codeclimate.yml").must_equal(true)

          stdout, _ = capture_io do
            Init.new(["--upgrade"]).run
          end

          content_after = File.read(".codeclimate.yml")

          filesystem.exist?(".codeclimate.yml").must_equal(true)
          content_after.must_equal(yaml_content_before)

          stdout.must_match "--upgrade should not be used on a .codeclimate.yml configured for the Platform"
        end

        it "behaves normally if no .codeclimate.yml present" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)
          write_fixture_source_files

          stdout, _ = capture_io do
            Init.new(["--upgrade"]).run
          end

          stdout.must_match "Config file .codeclimate.yml successfully generated."

          new_content = File.read(".codeclimate.yml")
          YAML.safe_load(new_content).must_equal({
            "engines" => {
              "rubocop" => { "enabled"=>true },
              "eslint" => { "enabled"=>true },
              "csslint" => { "enabled"=>true },
              "duplication" => {
                "enabled" => true,
                "config" => { "languages" => ["ruby"] }
              }
            },
            "ratings" => { "paths" => ["**.rb", "**.js", "**.jsx", "**.css"] },
            "exclude_paths" => ["config/**/*", "spec/**/*", "vendor/**/*"],
          })

          CC::Yaml.parse(new_content).errors.must_be_empty
        end

        it "upgrades if classic config is present" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)

          File.write(".codeclimate.yml", create_classic_yaml)

          filesystem.exist?(".codeclimate.yml").must_equal(true)

          write_fixture_source_files

          stdout, _ = capture_io do
            Init.new(["--upgrade"]).run
          end

          stdout.must_match "Config file .codeclimate.yml successfully upgraded."

          new_content = File.read(".codeclimate.yml")
          YAML.safe_load(new_content).must_equal({
            "engines" => {
              "rubocop" => { "enabled"=>true },
              "csslint" => { "enabled"=>true },
              "duplication" => {
                "enabled" => true,
                "config" => { "languages" => ["ruby"] }
              }
            },
            "ratings" => { "paths" => ["**.rb", "**.css"] },
            "exclude_paths" => ["excluded.rb"],
          })

          CC::Yaml.parse(new_content).errors.must_be_empty
        end
      end
    end

    def filesystem
      @filesystem ||= make_filesystem
    end
  end
end
