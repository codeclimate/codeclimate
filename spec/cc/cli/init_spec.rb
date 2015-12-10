require "spec_helper"
require "cc/yaml"

module CC::CLI
  describe Init do
    include Factory
    include FileSystemHelpers
    include ProcHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "#run" do
      describe "when no .codeclimate.yml file is present in working directory" do
        it "creates a correct .codeclimate.yml file and reports successful creation" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)
          write_fixture_source_files

          stdout, _, exit_code = capture_io_and_exit_code do
            init = Init.new
            init.run
          end

          new_content = File.read(".codeclimate.yml")

          stdout.must_match "Config file .codeclimate.yml successfully generated."
          exit_code.must_equal 0
          filesystem.exist?(".codeclimate.yml").must_equal(true)

          YAML.safe_load(new_content).must_equal({
            "engines" => {
              "csslint" => { "enabled"=>true },
              "duplication" => { "enabled" => true, "config" => { "languages" => ["ruby", "javascript", "python", "php"] } },
              "eslint" => { "enabled"=>true },
              "fixme" => { "enabled"=>true },
              "rubocop" => { "enabled"=>true },
            },
            "ratings" => { "paths" => ["**.css", "**.js", "**.jsx", "**.php", "**.py", "**.rb"] },
            "exclude_paths" => ["config/**/*", "spec/**/*", "vendor/**/*"],
          })

          CC::Yaml.parse(new_content).errors.must_be_empty
        end

        describe 'when default config for engine is available' do
          describe 'when no config file for this engine exists in working directory' do
            it 'creates .engine.yml with default config' do
              File.write('foo.rb', 'class Foo; end')

              stdout, _, exit_code = capture_io_and_exit_code do
                init = Init.new
                init.run
              end

              new_content = File.read('.rubocop.yml')

              stdout.must_match 'Config file .rubocop.yml successfully generated.'
              exit_code.must_equal 0
              filesystem.exist?('.rubocop.yml').must_equal(true)
              YAML.safe_load(new_content).keys.must_include('AllCops')
            end
          end

          describe 'when config file for this engine already exists in working directory' do
            it 'skips engine config file generation' do
              File.write('foo.rb', 'class Foo; end')

              content_before = 'test content'
              File.write('.rubocop.yml', content_before)

              stdout, _, _ = capture_io_and_exit_code do
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

          capture_io_and_exit_code do
            Init.new.run
          end

          content_after = File.read(".codeclimate.yml")

          filesystem.exist?(".codeclimate.yml").must_equal(true)
          content_after.must_equal(yaml_content_before)
        end

        it "warns that there is a .codeclimate.yml file already present" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)

          File.new(".codeclimate.yml", "w")

          filesystem.exist?(".codeclimate.yml").must_equal(true)

          stdout, _, exit_code = capture_io_and_exit_code do
            Init.new.run
          end

          stdout.must_match("WARNING: Config file .codeclimate.yml already present.")
          exit_code.must_equal 0
        end

        it "still generates default config files" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)

          File.new(".codeclimate.yml", "w")

          filesystem.exist?(".codeclimate.yml").must_equal(true)

          init = Init.new

          init.expects(:create_default_configs)

          _, stderr, exit_code = capture_io_and_exit_code do
            init.run
          end
        end
      end

      describe "when --upgrade flag is on" do
        it "refuses to upgrade a platform config" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)

          yaml_content_before = yaml_with_rubocop_enabled
          File.write(".codeclimate.yml", yaml_content_before)

          filesystem.exist?(".codeclimate.yml").must_equal(true)

          _, stderr, exit_code = capture_io_and_exit_code do
            Init.new(["--upgrade"]).run
          end

          content_after = File.read(".codeclimate.yml")

          filesystem.exist?(".codeclimate.yml").must_equal(true)
          content_after.must_equal(yaml_content_before)

          stderr.must_match "--upgrade should not be used on a .codeclimate.yml configured for the Platform"
          exit_code.must_equal 1
        end

        it "behaves normally if no .codeclimate.yml present" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)
          write_fixture_source_files

          stdout, _, _ = capture_io_and_exit_code do
            Init.new(["--upgrade"]).run
          end

          stdout.must_match "Config file .codeclimate.yml successfully generated."

          new_content = File.read(".codeclimate.yml")
          YAML.safe_load(new_content).must_equal({
            "engines" => {
              "csslint" => { "enabled"=>true },
              "duplication" => { "enabled" => true, "config" => { "languages" => ["ruby", "javascript", "python", "php"] } },
              "eslint" => { "enabled"=>true },
              "fixme" => { "enabled"=>true },
              "rubocop" => { "enabled"=>true },
            },
            "ratings" => { "paths" => ["**.css", "**.js", "**.jsx", "**.php", "**.py", "**.rb"] },
            "exclude_paths" => ["config/**/*", "spec/**/*", "vendor/**/*"],
          })

          CC::Yaml.parse(new_content).errors.must_be_empty
        end

        it "upgrades if classic config is present" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)

          File.write(".codeclimate.yml", create_classic_yaml)

          filesystem.exist?(".codeclimate.yml").must_equal(true)

          write_fixture_source_files

          stdout, _, _ = capture_io_and_exit_code do
            Init.new(["--upgrade"]).run
          end

          stdout.must_match "Config file .codeclimate.yml successfully upgraded."

          new_content = File.read(".codeclimate.yml")
          YAML.safe_load(new_content).must_equal({
            "engines" => {
              "csslint" => { "enabled"=>true },
              "duplication" => { "enabled" => true, "config" => { "languages" => ["ruby", "javascript", "python", "php"] } },
              "fixme" => { "enabled"=>true },
              "rubocop" => { "enabled"=>true },
            },
            "ratings" => { "paths" => ["**.css", "**.js", "**.jsx", "**.php", "**.py", "**.rb"] },
            "exclude_paths" => ["excluded.rb"],
          })

          CC::Yaml.parse(new_content).errors.must_be_empty
        end

        it "fails & emits errors if existing yaml has errors" do
          filesystem.exist?(".codeclimate.yml").must_equal(false)

          File.write(".codeclimate.yml", %{
            languages:
              Ruby:
                bar: foo

            exclude_paths:
              - excluded.rb
          })

          _, stderr, exit_code = capture_io_and_exit_code do
            Init.new(["--upgrade"]).run
          end

          stderr.must_match "ERROR: invalid \"languages\" section"
          stderr.must_match "Cannot generate .codeclimate.yml"
          exit_code.must_equal 1
        end
      end
    end

    def filesystem
      @filesystem ||= make_filesystem
    end
  end
end
