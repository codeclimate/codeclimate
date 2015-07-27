require "spec_helper"

module CC::CLI::Engines
  describe Install do
    include FileSystemHelpers
    include CC::Yaml::TestHelpers

    describe "#run" do
      it "pulls uninstalled images using docker" do
        within_temp_dir do
          create_codeclimate_yaml(<<-YAML)
          engines:
            madeup:
              enabled: true
          YAML
          stub_engine_registry(list: {
            "madeup" => { "image" => "madeup_img" }
          })

          expect_system("docker pull madeup_img")

          capture_io { Install.new.run }
        end
      end

      it "warns for invalid engine names" do
        within_temp_dir do
          create_codeclimate_yaml(<<-YAML)
          engines:
            madeup:
              enabled: true
          YAML
          stub_engine_registry(list: {})

          stdout, _ = capture_io do
            Install.new.run
          end

          stdout.must_match(/unknown engine name: madeup/)
        end
      end

      it "errors if an image is unable to be pulled" do
        within_temp_dir do
          create_codeclimate_yaml(<<-YAML)
          engines:
            madeup:
              enabled: true
          YAML
          stub_engine_registry(list: {
            "madeup" => { "image" => "madeup_img" }
          })

          expect_system("docker pull madeup_img", false)

          capture_io do
            lambda { Install.new.run }.must_raise(Install::ImagePullFailure)
          end
        end
      end
    end

    def expect_system(cmd, result = true)
      Install.any_instance.expects(:system).with(cmd).returns(result)
    end

    def stub_engine_registry(stubs)
      registry = stub(stubs)
      CC::Analyzer::EngineRegistry.stubs(:new).returns(registry)
    end
  end
end
