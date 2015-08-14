require "spec_helper"

module CC::Analyzer
  describe Engine do
    before do
      FileUtils.mkdir_p("/tmp/cc")
    end

    describe "#run" do
      it "passes the correct options to Container" do
        container = stub
        container.stubs(:on_output).yields("")
        container.stubs(:run)

        Container.expects(:new).with do |args|
          args[:image].must_equal "codeclimate/foo"
          args[:command].must_equal "bar"
          args[:name].must_match /^cc-engines-foo/
        end.returns(container)

        metadata = { "image" => "codeclimate/foo", "command" => "bar" }
        engine = Engine.new("foo", metadata, "", {}, "")
        engine.run(stdout_io: StringIO.new)
      end

      it "runs a Container in a constrained environment" do
        container = stub
        container.stubs(:on_output).yields("")

        container.expects(:run).with(includes(
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=a-label",
          "--memory", "512000000",
          "--memory-swap", "-1",
          "--net", "none",
          "--volume", "/code:/code:ro",
          "--user", "9000:9000",
        ))

        Container.expects(:new).returns(container)
        engine = Engine.new("", {}, "/code", {}, "a-label")
        engine.run(stdout_io: StringIO.new)
      end

      it "passes its container log wrapping the given one" do
        container = stub
        container.stubs(:on_output).yields("")
        container.stubs(:run)

        given_log = stub
        container_log = stub
        Engine::ContainerLog.expects(:new).with("foo", given_log).returns(container_log)
        Container.expects(:new).with(has_entry(log: container_log)).returns(container)

        engine = Engine.new("foo", {}, "", {}, "")
        engine.run(stdout_io: StringIO.new, container_log: given_log)
      end

      it "parses stdout for null-delimited issues" do
        container = TestContainer.new([
          "issue one",
          "issue two",
          "issue three",
        ])
        Container.expects(:new).returns(container)

        stdout = StringIO.new
        engine = Engine.new("", {}, "", {}, "")
        engine.run(stdout_io: stdout)

        stdout.string.must_equal "issue oneissue twoissue three"
      end

      it "supports issue filtering by check name" do
        container = TestContainer.new([
          %{{"type":"issue","check":"foo"}},
          %{{"type":"issue","check":"bar"}},
          %{{"type":"issue","check":"baz"}},
        ])
        Container.expects(:new).returns(container)

        stdout = StringIO.new
        config = { "checks" => { "bar" => { "enabled" => false } } }
        engine = Engine.new("", {}, "", config, "")
        engine.run(stdout_io: stdout)

        stdout.string.wont_match(%{"check":"bar"})
      end
    end
  end
end
