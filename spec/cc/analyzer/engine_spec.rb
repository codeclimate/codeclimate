require "spec_helper"

module CC::Analyzer
  describe Engine do
    let(:metadata) { { "image" => "codeclimate/foo", "command" => "bar", "memory" => 1024000000 } }

    describe "#run" do
      it "passes the correct options to Container" do
        container = double
        allow(container).to receive(:on_output).and_yield("")
        allow(container).to receive(:run).and_return(Container::Result.new)

        expect(Container).to receive(:new) do |args|
          expect(args[:image]).to eq "codeclimate/foo"
          expect(args[:command]).to eq "bar"
          expect(args[:name]).to match(/^cc-engines-foo/)
        end.and_return(container)

        engine = Engine.new("foo", metadata, {}, "")
        engine.run(StringIO.new)
      end

      it "runs a Container in a constrained environment" do
        container = double
        allow(container).to receive(:on_output).and_yield("")

        expect(container).to receive(:run).with(including(
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=a-label",
          "--memory", "1024000000",
          "--memory-swap", "-1",
          "--net", "none",
          "--rm",
          "--user", "9000:9000",
        )).and_return(Container::Result.new)

        expect(Container).to receive(:new).and_return(container)
        engine = Engine.new("", metadata, {}, "a-label")
        engine.run(StringIO.new)
      end

      it "runs a Container with engine memory overrides" do
        container = double
        allow(container).to receive(:on_output).and_yield("")

        expect(container).to receive(:run).with(including(
          "--memory", "2048000000",
        )).and_return(Container::Result.new)

        expect(Container).to receive(:new).and_return(container)
        engine = Engine.new("", { "image" => "", "memory" => 2048000000 }, {}, "a-label")
        engine.run(StringIO.new)
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
          engine = Engine.new("bar", metadata, {}, "")
          engine.run(stdout)

          expected = "{\"engine_name\":\"bar\",\"fingerprint\":\"bdc0c2bb1201c4739118a51481a86fa1\",\"type\":\"issue\",\"check_name\":\"foo\",\"location\":{\"path\":\"foo.rb\",\"lines\":{\"begin\":1,\"end\":1}},\"description\":\"foo\",\"categories\":[\"Style\"],\"severity\":\"minor\"}{\"engine_name\":\"bar\",\"fingerprint\":\"cbd5b8962eb9e2950fbb02f0ddf6c404\",\"type\":\"issue\",\"check_name\":\"bar\",\"location\":{\"path\":\"foo.rb\",\"lines\":{\"begin\":1,\"end\":1}},\"description\":\"foo\",\"categories\":[\"Style\"],\"severity\":\"minor\"}{\"engine_name\":\"bar\",\"fingerprint\":\"a08df13d51af2259c425551cb84c135f\",\"type\":\"issue\",\"check_name\":\"baz\",\"location\":{\"path\":\"foo.rb\",\"lines\":{\"begin\":1,\"end\":1}},\"description\":\"foo\",\"categories\":[\"Style\"],\"severity\":\"minor\"}"
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
          engine = Engine.new("", metadata, config, "")
          engine.run(stdout)

          expect(stdout.string).not_to include %{"check":"bar"}
        end
      end

      it "applies overrides" do
        within_temp_dir do
          make_file("foo.rb")

          container = TestContainer.new([
            %{{"type":"issue","check_name":"foo","location":{"path":"foo.rb","lines":{"begin":1,"end":1}},"description":"foo","categories":["Style"],"severity":"minor"}},
          ])
          expect(Container).to receive(:new).and_return(container)

          stdout = StringIO.new
          config = { "issue_override" => { "severity" => "info" } }
          engine = Engine.new("", metadata, config, "")
          engine.run(stdout)

          expect(stdout.string).not_to include %{"severity":"minor"}
          expect(stdout.string).to include %{"severity":"info"}
        end
      end
    end
  end
end
