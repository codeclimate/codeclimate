require "spec_helper"

module CC::Analyzer
  describe Container do
    describe "#run" do
      it "spawns docker run with the image, name, and options given" do
        container = Container.new(image: "codeclimate/foo", name: "name")

        expect_spawn(%w[ docker run --name name -i -t codeclimate/foo ])

        container.run(%w[ -i -t ])
      end

      it "spawns the command if present" do
        container = Container.new(image: "codeclimate/foo", command: "bar", name: "name")

        expect_spawn(%w[ docker run --name name codeclimate/foo bar ])

        container.run
      end

      it "spawns an array command if given" do
        container = Container.new(image: "codeclimate/foo", command: %w[ bar baz ], name: "name")

        expect_spawn(%w[ docker run --name name codeclimate/foo bar baz ])

        container.run
      end

      it "spawns an array command with spaces" do
        container = Container.new(
          image: "codeclimate/foo",
          command: %w[ bar baz\ bat ],
          name: "name",
        )

        expect_spawn(%w[ docker run --name name codeclimate/foo bar baz\ bat ])

        container.run
      end

      it "sends output to the defined handler splitting on the defined delimiter" do
        collected_output = []
        container = Container.new(image: "codeclimate/foo", name: "name")
        container.on_output("\0") { |output| collected_output << output }

        out = StringIO.new
        out.write("foo\0bar\0")
        out.rewind
        stub_spawn(out: out)

        container.run

        expect(collected_output).to eq %w[ foo bar ]
      end

      it "returns a result object" do
        container = Container.new(image: "codeclimate/foo", name: "name")
        stub_spawn
        result = container.run
        expect(result.exit_status).to eq 0
        expect(result.timed_out?).to eq false
        expect(result.duration).to be_between(-1, 2_000)
        expect(result.stderr).to eq ""
      end

      # N.B. these specs actually docker-runs things. This logic is critical and
      # so the real-world interaction is valuable.
      describe "stopping containers", slow: true do
        before do
          @name = "codeclimate-container-test"
          system("docker kill #{@name} &>/dev/null")
          system("docker rm #{@name} &>/dev/null")
        end

        it "can be stopped" do
          container = Container.new(
            image: "alpine",
            command: %w[sleep 10],
            name: @name,
          )

          run_container(container) do |c|
            # it needs a second to boot before stop will work
            sleep 2
            c.stop
          end

          assert_container_stopped
          expect(@container_result.timed_out?).to eq false
          expect(@container_result.exit_status).to be_present
          expect(@container_result.duration).to be_between(-1, 10_000)
        end

        it "times out slow containers" do
          with_timeout(1) do
            container = Container.new(
              image: "alpine",
              command: %w[sleep 10],
              name: @name,
            )

            run_container(container)

            assert_container_stopped
            expect(@container_result.timed_out?).to eq true
            expect(@container_result.exit_status).to be_present
            expect(@container_result.duration).to be_between(-1, 2_000)
          end
        end

        it "waits for IO parsing to finish" do
          stdout_lines = []
          container = Container.new(
            image: "alpine",
            command: ["echo", "line1\nline2\nline3"],
            name: @name,
          )
          container.on_output do |str|
            sleep 0.5
            stdout_lines << str
          end

          run_container(container)

          assert_container_stopped
          expect(@container_result.timed_out?).to eq false
          expect(stdout_lines).to eq %w[line1 line2 line3]
        end

        it "does not wait for IO when timed out" do
          with_timeout(1) do
            container = Container.new(
              image: "alpine",
              #command: %w[sleep 10],
              command: ["echo", "line1\nline2\nline3"],
              name: @name,
            )
            container.on_output do |str|
              sleep 10 and raise "Reader thread was not killed"
            end

            run_container(container)

            assert_container_stopped
          end
        end

        it "stops containers that emit more than the configured maximum output bytes" do
          begin
            ENV["CONTAINER_MAXIMUM_OUTPUT_BYTES"] = "4"
            container = Container.new(
              image: "alpine",
              command: ["echo", "hello"],
              name: @name,
            )

            run_container(container)

            assert_container_stopped
            expect(@container_result.maximum_output_exceeded?).to eq true
            expect(@container_result.timed_out?).to eq false
            expect(@container_result.exit_status).to be_present
            expect(@container_result.output_byte_count).to be > 4
          ensure
            ENV.delete("CONTAINER_MAXIMUM_OUTPUT_BYTES")
          end
        end

        it "rescues and records metrics when containers fail to stop" do
          with_timeout(1) do
            name = "cc-engines-rubocop-stable-abc-123"
            container = Container.new(
              image: "alpine",
              command: %w[sleep 10],
              name: "cc-engines-rubocop-stable-abc-123",
            )

            allow(Timeout).to receive(:timeout).
              and_raise(Timeout::Error)

            expect(CC::Analyzer.logger).to receive(:error)
            expect(CC::Analyzer.statsd).to receive(:increment).
              with("container.zombie")
            expect(CC::Analyzer.statsd).to receive(:increment).
              with("container.zombie.engine.rubocop.stable")

            begin
              run_container(container)
            ensure
              # Cleanup manually
              system("docker stop #{name} >/dev/null")
              system("docker rm #{name} >/dev/null")
            end
          end
        end

        def run_container(container)
          thread = Thread.new { @container_result = container.run }

          if block_given?
            yield container
          else
            container
          end
        ensure
          thread&.join
        end

        def assert_container_stopped
          expect(`docker ps --quiet --filter name=#{@name}`.strip).to eq ""
        end
      end
    end

    describe "#run when the process exits with a non-zero status" do
      before do
        @container = Container.new(image: "codeclimate/foo", name: "name")
        err = StringIO.new
        err.puts("error one")
        err.puts("error two")
        err.rewind
        status = double("Process::Status", exitstatus: 123)
        stub_spawn(status: status, err: err)
      end

      it "returns a result object" do
        result = @container.run
        expect(result.exit_status).to eq 123
        expect(result.timed_out?).to eq false
        expect(result.duration).to be_present
        expect(result.stderr).to eq "error one\nerror two\n"
      end
    end

    def stub_spawn(status: nil, out: StringIO.new, err: StringIO.new)
      wait_thr = double("Process::Waiter", pid: 42)
      status ||= double("Process::Status", exitstatus: 0)

      allow(Open3).to receive(:popen3).and_return([nil, out, err, wait_thr])
      allow(wait_thr).to receive(:value).and_return(status)

      return [nil, out, err, wait_thr]
    end

    def expect_spawn(args, status: nil, out: StringIO.new, err: StringIO.new)
      wait_thr = double("Process::Waiter", pid: 42)
      status ||= double("Process::Status", exitstatus: 0)

      expect(Open3).to receive(:popen3).with(*args).and_return([nil, out, err, wait_thr])
      expect(wait_thr).to receive(:value).and_return(status)

      return [nil, out, err, wait_thr]
    end

    def with_timeout(timeout)
      old_timeout = ENV["CONTAINER_TIMEOUT_SECONDS"]
      ENV["CONTAINER_TIMEOUT_SECONDS"] = timeout.to_s
      yield
    ensure
      ENV["CONTAINER_TIMEOUT_SECONDS"] = old_timeout
    end
  end
end
