require "spec_helper"

module CC::Analyzer
  describe Container do
    describe "#run" do
      it "spawns docker run with the image, name, and options given" do
        container = Container.new(image: "codeclimate/foo", name: "name")

        expect_spawn(%w[ docker run --rm --name name -i -t codeclimate/foo ])

        container.run(%w[ -i -t ])
      end

      it "spawns the command if present" do
        container = Container.new(image: "codeclimate/foo", command: "bar", name: "name")

        expect_spawn(%w[ docker run --rm --name name codeclimate/foo bar ])

        container.run
      end

      it "spawns an array command if given" do
        container = Container.new(image: "codeclimate/foo", command: %w[ bar baz ], name: "name")

        expect_spawn(%w[ docker run --rm --name name codeclimate/foo bar baz ])

        container.run
      end

      it "spawns an array command with spaces" do
        container = Container.new(
          image: "codeclimate/foo",
          command: %w[ bar baz\ bat ],
          name: "name",
        )

        expect_spawn(%w[ docker run --rm --name name codeclimate/foo bar baz\ bat ])

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

        collected_output.must_equal %w[ foo bar ]
      end

      it "logs a start event to the given container listener" do
        stub_spawn
        listener = TestContainerListener.new
        container = Container.new(image: "codeclimate/foo", name: "name", listener: listener)

        container.run

        listener.started_image.must_equal "codeclimate/foo"
        listener.started_name.must_equal "name"
      end

      it "logs a finished event with status and stderr" do
        listener = TestContainerListener.new
        container = Container.new(image: "codeclimate/foo", name: "name", listener: listener)

        err = StringIO.new
        err.puts("error one")
        err.puts("error two")
        err.rewind
        status = stub("Process::Status", exitstatus: 123)
        stub_spawn(status: status, err: err)

        container.run

        listener.finished_image.must_equal "codeclimate/foo"
        listener.finished_name.must_equal "name"
        listener.finished_stderr.must_equal "error one\nerror two\n"
      end

      it "returns a result object" do
        container = Container.new(image: "codeclimate/foo", name: "name")
        stub_spawn
        result = container.run
        result.exit_status.must_equal 0
        result.timed_out?.must_equal false
        (result.duration >= 0).must_equal true
        (result.duration < 1).must_equal true
        result.stderr.must_equal ""
      end

      # N.B. these specs actually docker-runs things. This logic is critical and
      # so the real-world interaction is valuable.
      describe "stopping containers" do
        before do
          @name = "codeclimate-container-test"
          system("docker kill #{@name} &>/dev/null")
          system("docker rm #{@name} &>/dev/null")
        end

        it "can be stopped" do
          listener = TestContainerListener.new
          listener.expects(:timed_out).never
          container = Container.new(
            image: "alpine",
            command: %w[sleep 10],
            name: @name,
            listener: listener,
            timeout: 5,
          )

          run_container(container) do |c|
            # it needs a second to boot before stop will work
            sleep 1
            c.stop
          end

          assert_container_stopped
          listener.finished_image.must_equal "alpine"
          listener.finished_name.must_equal @name
          (@container_result.exit_status != 0).must_equal true
          @container_result.timed_out?.must_equal false
          (@container_result.duration >= 0).must_equal true
          (@container_result.duration < 2_000).must_equal true
          @container_result.stderr.must_equal ""
        end

        it "times out slow containers" do
          listener = TestContainerListener.new
          listener.expects(:finished).never
          container = Container.new(
            image: "alpine",
            command: %w[sleep 10],
            name: @name,
            listener: listener,
            timeout: 1,
          )

          run_container(container)

          assert_container_stopped
          listener.timed_out?.must_equal true
          listener.timed_out_image.must_equal "alpine"
          listener.timed_out_name.must_equal @name
          listener.timed_out_seconds.must_equal 1
          (@container_result.exit_status != 0).must_equal true
          @container_result.timed_out?.must_equal true
          (@container_result.duration >= 0).must_equal true
          (@container_result.duration < 2_000).must_equal true
          @container_result.stderr.must_equal ""
        end

        def run_container(container)
          thread = Thread.new { @container_result = container.run }

          if block_given?
            yield container
          else
            container
          end
        ensure
          thread.join if thread
        end

        def assert_container_stopped
          `docker ps --quiet --filter name=#{@name}`.strip.must_equal ""
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
        status = stub("Process::Status", exitstatus: 123)
        stub_spawn(status: status, err: err)
      end

      it "returns a result object" do
        result = @container.run
        result.exit_status.must_equal 123
        result.timed_out?.must_equal false
        (result.duration >= 0).must_equal true
        (result.duration < 1).must_equal true
        result.stderr.must_equal "error one\nerror two\n"
      end
    end

    describe "new with a blank image" do
      it "raises an exception" do
        -> { CC::Analyzer::Container.new(image: "", name: "name") }.must_raise(CC::Analyzer::Container::ImageRequired)
      end
    end

    def stub_spawn(status: nil, out: StringIO.new, err: StringIO.new)
      pid = 42
      status ||= stub("Process::Status", exitstatus: 0)

      POSIX::Spawn.stubs(:popen4).returns([pid, nil, out, err])
      Process.stubs(:waitpid2).with(pid).returns([nil, status])

      return [pid, out, err]
    end

    def expect_spawn(args, status: nil, out: StringIO.new, err: StringIO.new)
      pid = 42
      status ||= stub("Process::Status", exitstatus: 0)

      POSIX::Spawn.expects(:popen4).with(*args).returns([pid, nil, out, err])
      Process.expects(:waitpid2).with(pid).returns([nil, status])

      return [pid, out, err]
    end
  end
end
