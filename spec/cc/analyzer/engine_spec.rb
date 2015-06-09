require "spec_helper"
require "cc/analyzer"

describe CC::Analyzer::Engine do
  describe "#run" do
    it "creates a container based on the metadata image" do
      metadata = { "image_name" => "codeclimate/image-name", "command" => "run" }
      engine = CC::Analyzer::Engine.new("rubocop", metadata, "/path", 'sup')

      expect_container_create(
        "Image" => "codeclimate/image-name",
        "Cmd" => "run",
        "MemorySwap" => -1,
        "Memory" => 512000000,
        "Labels" => { "com.codeclimate.label" => 'sup' },
        "NetworkDisabled" => true,
        "CapDrop" => ["ALL"],
        "Binds"=>[
          "/path:/code:ro"
        ]
      )

      engine.run(StringIO.new)
    end

    def expect_container_create(options)
      container = stub(id: "1", start: nil, wait: true, attach: nil)
      Docker::Container.expects(:create).with(options).returns(container)
    end
  end
end

