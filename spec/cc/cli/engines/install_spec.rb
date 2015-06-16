require "spec_helper"

module CC::CLI::Engines
  describe Install do
    describe "#run" do
      it "pulls uninstalled images using docker" do
        stub_config(engine_names: ["madeup"])
        stub_engine_registry(list: {
          "madeup" => { "image_name" => "madeup_img" }
        })

        expect_system("docker history madeup_img > /dev/null 2>&1", false)
        expect_system("docker pull madeup_img")

        capture_io { Install.new.run }
      end

      it "warns for invalid engine names" do
        stub_config(engine_names: ["madeup"])
        stub_engine_registry(list: {})

        stdout, _ = capture_io do
          Install.new.run
        end

        stdout.must_match(/unknown engine name: madeup/)
      end

      it "errors if an image is unable to be pulled" do
        stub_config(engine_names: ["madeup"])
        stub_engine_registry(list: {
          "madeup" => { "image_name" => "madeup_img" }
        })

        expect_system("docker history madeup_img > /dev/null 2>&1", false)
        expect_system("docker pull madeup_img", false)

        capture_io do
          lambda { Install.new.run }.must_raise(Install::ImagePullFailure)
        end
      end

    end

    def expect_system(cmd, result = true)
      Install.any_instance.expects(:system).with(cmd).returns(result)
    end

    def stub_config(stubs)
      config = stub(stubs)
      CC::Analyzer::Config.stubs(:new).returns(config)
    end

    def stub_engine_registry(stubs)
      registry = stub(stubs)
      CC::Analyzer::EngineRegistry.stubs(:new).returns(registry)
    end
  end
end
