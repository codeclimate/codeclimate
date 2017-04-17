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
          expect(filesystem.exist?(".codeclimate.yml")).to eq(false)
          write_fixture_source_files

          stdout, _, exit_code = capture_io_and_exit_code do
            init = Init.new
            init.run
          end

          new_content = File.read(".codeclimate.yml")

          expect(stdout).to include("Config file .codeclimate.yml successfully generated.")
          expect(exit_code).to eq 0
          expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

          config = YAML.safe_load(new_content)
          expect(config).to eq(
            "engines" => {
              "csslint" => { "enabled"=>true },
              "duplication" => { "enabled" => true, "config" => { "languages" => ["ruby", "javascript", "python", "php"] } },
              "eslint" => { "enabled"=>true },
              "fixme" => { "enabled"=>true },
              "rubocop" => { "enabled"=>true },
            },
            "ratings" => { "paths" => ["**.css", "**.inc", "**.js", "**.jsx", "**.module", "**.php", "**.py", "**.rb"] },
            "exclude_paths" => ["config/", "spec/", "vendor/"],
          )

          expect(CC::Yaml.parse(new_content).errors).to be_empty
        end

        it "runs when the directory is empty" do
          _, _, exit_code = capture_io_and_exit_code do
            init = Init.new
            init.run
          end

          expect(exit_code).to eq(0)
          config = YAML.safe_load(File.read(".codeclimate.yml"))
          expect(config).to eq({
            "engines" => {},
            "ratings" => { "paths" => [] },
            "exclude_paths" => []
          })
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

              expect(stdout).to include('Config file .rubocop.yml successfully generated.')
              expect(exit_code).to eq 0
              expect(filesystem.exist?('.rubocop.yml')).to eq(true)
              expect(YAML.safe_load(new_content).keys).to include('AllCops')
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

              expect(stdout).to include('Skipping generating .rubocop.yml, existing file(s) found: .rubocop.yml')
              expect(filesystem.exist?('.rubocop.yml')).to eq(true)
              expect(content_after).to eq(content_before)
            end

            it "skips engine config file generation when target file is present" do
              File.write("bar.js", "{}")

              filename = ".eslintrc.yml"
              content = "test content"
              File.write(filename, content)

              stdout, _, _ = capture_io_and_exit_code do
                Init.new.run
              end

              expect(stdout).to include("Skipping generating #{filename}, existing file(s) found: #{filename}")
              expect(filesystem.exist?(filename)).to eq(true)
              expect(content).to eq(File.read(filename))
            end
          end

          describe "when an invalid engine is specified" do
            it "does not error" do
              config = <<-EOF
                engines:
                  hal9000:
                    enabled: true
              EOF
              File.write(".codeclimate.yml", config)

              _, _, exit_code = capture_io_and_exit_code do
                init = Init.new
                init.run
              end

              expect(exit_code).to eq(0)
            end
          end
        end
      end

      describe "when a platform .codeclimate.yml file is already present in working directory" do
        it "does not create a new file or overwrite the old" do
          expect(filesystem.exist?(".codeclimate.yml")).to eq(false)

          yaml_content_before = "---\nlanguages:\n  Ruby: true\n"
          File.write(".codeclimate.yml", yaml_content_before)

          expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

          capture_io_and_exit_code do
            Init.new.run
          end

          content_after = File.read(".codeclimate.yml")

          expect(filesystem.exist?(".codeclimate.yml")).to eq(true)
          expect(content_after).to eq(yaml_content_before)
        end

        it "warns that there is a .codeclimate.yml file already present" do
          expect(filesystem.exist?(".codeclimate.yml")).to eq(false)

          File.new(".codeclimate.yml", "w")

          expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

          stdout, _, exit_code = capture_io_and_exit_code do
            Init.new.run
          end

          expect(stdout).to include("WARNING: Config file .codeclimate.yml already present.")
          expect(exit_code).to eq 0
        end

        it "still generates default config files" do
          expect(filesystem.exist?(".codeclimate.yml")).to eq(false)

          yaml = "---\nengines:\n  rubocop:\n    enabled: true"
          File.write(".codeclimate.yml", yaml)

          expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

          init = Init.new

          expect(init).to receive(:create_default_engine_configs)

          capture_io_and_exit_code do
            init.run
          end
        end

        it "doesn't overwrite existing engine configs" do
          yaml = "---\nengines:\n  rubocop:\n    enabled: true"
          default_config = File.read(File.expand_path("../../../config/rubocop/.rubocop.yml", __dir__))
          existing_config = default_config + "\n# This is not a default config\n"

          File.write(".codeclimate.yml", yaml)
          File.write(".rubocop.yml", existing_config)

          init = Init.new

          capture_io_and_exit_code do
            init.run
          end

          engine_config = File.read(".rubocop.yml")
          expect(engine_config).to_not eq(default_config)
          expect(engine_config).to eq(existing_config)
        end

        it "doesn't generate default configs when alternative configs exist" do
          yaml = "---\nengines:\n  rubocop:\n    enabled: true"

          File.write(".codeclimate.yml", yaml)
          File.write(".rubocop.yml.alt", "---\n")

          init = Init.new
          allow(init).to receive(:engine_registry).and_return(
            "rubocop" => {
              "config_files" => {
                ".rubocop.yml" => [".rubocop.yml.alt"],
              },
            },
          )

          capture_io_and_exit_code do
            init.run
          end

          expect(File.exist?(".rubocop.yml")).to eq false
        end
      end

      describe "when --upgrade flag is on" do
        it "generates engine configs for a platform .codeclimate.yml" do
          expect(filesystem.exist?(".codeclimate.yml")).to eq(false)

          yaml_content_before = yaml_with_rubocop_enabled
          File.write(".codeclimate.yml", yaml_content_before)

          expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

          init = Init.new(["--upgrade"])

          expect(init).to receive(:create_default_engine_configs)

          stdout, _, exit_code = capture_io_and_exit_code do
            init.run
          end

          content_after = File.read(".codeclimate.yml")

          expect(filesystem.exist?(".codeclimate.yml")).to eq(true)
          expect(content_after).to eq(yaml_content_before)

          expect(stdout).to include("configured for the Platform")
          expect(exit_code).to eq 0
        end

        it "behaves normally if no .codeclimate.yml present" do
          expect(filesystem.exist?(".codeclimate.yml")).to eq(false)
          write_fixture_source_files

          stdout, _, _ = capture_io_and_exit_code do
            Init.new(["--upgrade"]).run
          end

          expect(stdout).to include("Config file .codeclimate.yml successfully generated.")

          new_content = File.read(".codeclimate.yml")
          config = YAML.safe_load(new_content)
          expect(config).to eq(
            "engines" => {
              "csslint" => { "enabled"=>true },
              "duplication" => { "enabled" => true, "config" => { "languages" => ["ruby", "javascript", "python", "php"] } },
              "eslint" => { "enabled"=>true },
              "fixme" => { "enabled"=>true },
              "rubocop" => { "enabled"=>true },
            },
            "ratings" => { "paths" => ["**.css", "**.inc", "**.js", "**.jsx", "**.module", "**.php", "**.py", "**.rb"] },
            "exclude_paths" => ["config/", "spec/", "vendor/"],
          )

          expect(CC::Yaml.parse(new_content).errors).to be_empty
        end

        it "upgrades if classic config is present" do
          expect(filesystem.exist?(".codeclimate.yml")).to eq(false)

          File.write(".codeclimate.yml", create_classic_yaml)

          expect(filesystem.exist?(".codeclimate.yml")).to eq(true)

          write_fixture_source_files

          stdout, _, _ = capture_io_and_exit_code do
            Init.new(["--upgrade"]).run
          end

          expect(stdout).to include("Config file .codeclimate.yml successfully upgraded.")

          new_content = File.read(".codeclimate.yml")
          config = YAML.safe_load(new_content)
          expect(config).to eq(
            "engines" => {
              "csslint" => { "enabled"=>true },
              "duplication" => { "enabled" => true, "config" => { "languages" => ["ruby", "javascript", "python", "php"] } },
              "fixme" => { "enabled"=>true },
              "rubocop" => { "enabled"=>true },
            },
            "ratings" => { "paths" => ["**.css", "**.inc", "**.js", "**.jsx", "**.module", "**.php", "**.py", "**.rb"] },
            "exclude_paths" => ["excluded.rb"],
          )

          expect(CC::Yaml.parse(new_content).errors).to be_empty
        end

        it "fails & emits errors if existing yaml has errors" do
          expect(filesystem.exist?(".codeclimate.yml")).to eq(false)

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

          expect(stderr).to include("ERROR: invalid \"languages\" section")
          expect(stderr).to include("Cannot generate .codeclimate.yml")
          expect(exit_code).to eq 1
        end
      end
    end

    def filesystem
      @filesystem ||= make_filesystem
    end
  end
end
