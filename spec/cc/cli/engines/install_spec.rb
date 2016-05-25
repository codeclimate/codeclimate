require "spec_helper"

module CC::CLI::Engines
  describe Install do
    describe "#run" do
      it "pulls uninstalled images using docker" do
        stub_config(engine_names: ["madeup"])
        stub_engine_exists("madeup")
        stub_engine_image("madeup")

        expect_system("docker pull madeup_img")

        capture_io { Install.new.run }
      end

      it "warns for invalid engine names" do
        stub_config(engine_names: ["madeup"])

        stdout, _ = capture_io do
          Install.new.run
        end

        expect(stdout).to match(/unknown engine name: madeup/)
      end

      it "errors if an image is unable to be pulled" do
        stub_config(engine_names: ["madeup"])
        stub_engine_exists("madeup")
        stub_engine_image("madeup")

        expect_system("docker pull madeup_img", false)

        capture_io do
          expect { Install.new.run }.to raise_error(Install::ImagePullFailure)
        end
      end
    end

    def expect_system(cmd, result = true)
      allow_any_instance_of(Install).to receive(:system).
        with(cmd).and_return(result)
    end

    def stub_config(stubs)
      config = double(stubs)
      allow(CC::Analyzer::Config).to receive(:new).and_return(config)
    end

    def stub_engine_exists(engine)
      allow_any_instance_of(CC::Analyzer::EngineRegistry).to receive(:exists?).
        with(engine).and_return(true)
    end

    def stub_engine_image(engine)
      allow_any_instance_of(CC::Analyzer::EngineRegistry).to receive(:[]).with(engine).
        and_return("channels" => { "stable" => "#{engine}_img" })
    end
  end
end

