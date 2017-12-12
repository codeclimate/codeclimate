require "spec_helper"

module CC::CLI::Engines
  describe Install do
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "#run" do
      it "pulls uninstalled images using docker" do
        write_cc_yaml(YAML.dump("plugins" => { "madeup" => true}))
        stub_engine_registry(YAML.dump(
          "structure" => { "channels" => { "stable" => "structure" } },
          "duplication" => { "channels" => { "stable" => "duplication" } },
          "madeup" => { "channels" => { "stable" => "madeup", "beta" => "madeup:beta" } },
        ))

        install = Install.new

        expect_system(install, "docker pull structure")
        expect_system(install, "docker pull duplication")
        expect_system(install, "docker pull madeup")

        capture_io { install.run }
      end

      it "warns for invalid engine names" do
        write_cc_yaml(YAML.dump("plugins" => { "madeup" => true}))
        stub_engine_registry(YAML.dump(
          "foo" => { "channels" => { "stable" => "foo" } },
        ))

        install = Install.new

        expect(install).not_to receive(:system)

        stdout, _ = capture_io do
          install.run
        end

        expect(stdout).to match(/unknown engine <madeup:stable>/)
      end

      it "errors if an image is unable to be pulled" do
        write_cc_yaml(YAML.dump("plugins" => { "madeup" => true}))
        stub_engine_registry(YAML.dump(
          "structure" => { "channels" => { "stable" => "structure" } },
          "duplication" => { "channels" => { "stable" => "duplication" } },
          "madeup" => { "channels" => { "stable" => "madeup" } },
        ))

        install = Install.new

        expect_system(install, "docker pull structure")
        expect_system(install, "docker pull duplication")
        expect_system(install, "docker pull madeup", false)

        capture_io do
          expect { install.run }.to raise_error(Install::ImagePullFailure)
        end
      end
    end

    def expect_system(install, cmd, result = true)
      expect(install).to receive(:system).
        with(cmd).and_return(result)
    end

    def write_cc_yaml(yaml)
      make_file(CC::Config::YAMLAdapter::DEFAULT_PATH, yaml)
    end

    def stub_engine_registry(yaml)
      fh = Tempfile.new("engines.yml", Dir.pwd)
      path = fh.path
      fh.close; fh.unlink
      make_file(path, yaml)
      stub_const("CC::EngineRegistry::DEFAULT_MANIFEST_PATH", path)
    end
  end
end

