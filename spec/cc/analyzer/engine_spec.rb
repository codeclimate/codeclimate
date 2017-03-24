require "spec_helper"

module CC::Analyzer
  describe Engine do
    describe "#run" do
      it "passes the correct options to Container" do
        container = double
        allow(container).to receive(:on_output).and_yield("")
        allow(container).to receive(:run).and_return(
          Container::Result.new(0, false, 1, false, 10, ""),
        )

        expect(Container).to receive(:new) do |args|
          expect(args[:image]).to eq "codeclimate/foo"
          expect(args[:command]).to eq "bar"
          expect(args[:name]).to match(/^cc-engines-foo/)
        end.and_return(container)

        metadata = { "image" => "codeclimate/foo", "command" => "bar" }
        engine = Engine.new("foo", metadata, "", {}, "")
        engine.run(StringIO.new, ContainerListener.new)
      end

      it "runs a Container in a constrained environment" do
        container = double
        allow(container).to receive(:on_output).and_yield("")

        expect(container).to receive(:run).with(including(
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=a-label",
          "--memory", "512000000",
          "--memory-swap", "-1",
          "--net", "none",
          "--rm",
          "--volume", "/code:/code:ro",
          "--user", "9000:9000",
        )).and_return(Container::Result.new(0, false, 1, false, 10, ""))

        expect(Container).to receive(:new).and_return(container)
        engine = Engine.new("", {}, "/code", {}, "a-label")
        engine.run(StringIO.new, ContainerListener.new)
      end

      it "passes a composite container listener wrapping the given one" do
        container = double
        allow(container).to receive(:on_output).and_yield("")
        allow(container).to receive(:run).and_return(
          Container::Result.new(0, false, 1, false, 10, "")
        )

        given_listener = double
        container_listener = double
        expect(CompositeContainerListener).to receive(:new).
          with(
            given_listener,
            kind_of(LoggingContainerListener),
            kind_of(StatsdContainerListener),
            kind_of(RaisingContainerListener),
          ).
          and_return(container_listener)
        expect(Container).to receive(:new).
          with(including(listener: container_listener)).and_return(container)

        engine = Engine.new("", {}, "", {}, "")
        engine.run(StringIO.new, given_listener)
      end

      it "parses stdout for null-delimited issues" do
        within_temp_dir do
          make_file("foo.rb")

          container = TestContainer.new([
            %{{"type":"issue","check_name":"foo","location":{"path":"foo.rb","lines":{"begin":1,"end":1}},"description":"foo","categories":["Style"]}},
            %{{"type":"issue","check_name":"bar","location":{"path":"foo.rb","lines":{"begin":1,"end":1}},"description":"foo","categories":["Style"]}},
            %{{"type":"issue","check_name":"baz","location":{"path":"foo.rb","lines":{"begin":1,"end":1}},"description":"foo","categories":["Style"]}},
          ])
          expect(Container).to receive(:new).and_return(container)

          stdout = TestFormatter.new
          engine = Engine.new("", {}, "", {}, "")
          engine.run(stdout, ContainerListener.new)

          expected = "{\"type\":\"issue\",\"check_name\":\"foo\",\"location\":{\"path\":\"foo.rb\",\"lines\":{\"begin\":1,\"end\":1}},\"description\":\"foo\",\"categories\":[\"Style\"],\"fingerprint\":\"bdc0c2bb1201c4739118a51481a86fa1\",\"severity\":\"minor\"}{\"type\":\"issue\",\"check_name\":\"bar\",\"location\":{\"path\":\"foo.rb\",\"lines\":{\"begin\":1,\"end\":1}},\"description\":\"foo\",\"categories\":[\"Style\"],\"fingerprint\":\"cbd5b8962eb9e2950fbb02f0ddf6c404\",\"severity\":\"minor\"}{\"type\":\"issue\",\"check_name\":\"baz\",\"location\":{\"path\":\"foo.rb\",\"lines\":{\"begin\":1,\"end\":1}},\"description\":\"foo\",\"categories\":[\"Style\"],\"fingerprint\":\"a08df13d51af2259c425551cb84c135f\",\"severity\":\"minor\"}"

          expect(stdout.string).to eq expected
        end
      end

      it "supports issue filtering by check name" do
        within_temp_dir do
          make_file("foo.rb")

          container = TestContainer.new([
            %{{"type":"issue","check_name":"foo","location":{"path":"foo.rb","lines":{"begin":1,"end":1}},"description":"foo","categories":["Style"]}},
            %{{"type":"issue","check_name":"bar","location":{"path":"foo.rb","lines":{"begin":1,"end":1}},"description":"foo","categories":["Style"]}},
            %{{"type":"issue","check_name":"baz","location":{"path":"foo.rb","lines":{"begin":1,"end":1}},"description":"foo","categories":["Style"]}},
          ])
          expect(Container).to receive(:new).and_return(container)

          stdout = StringIO.new
          config = { "checks" => { "bar" => { "enabled" => false } } }
          engine = Engine.new("", {}, "", config, "")
          engine.run(stdout, ContainerListener.new)

          expect(stdout.string).not_to include %{"check":"bar"}
        end
      end
    end
  end
end
