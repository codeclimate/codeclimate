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

      it "logs a start event to the given container log" do
        stub_spawn
        log = TestContainerLog.new
        container = Container.new(image: "codeclimate/foo", name: "name", log: log)

        container.run

        log.started_image.must_equal "codeclimate/foo"
        log.started_name.must_equal "name"
      end

      it "logs a finished event with status and stderr" do
        log = TestContainerLog.new
        container = Container.new(image: "codeclimate/foo", name: "name", log: log)

        err = StringIO.new
        err.puts("error one")
        err.puts("error two")
        err.rewind
        stub_spawn(status: :failed, err: err)

        container.run

        log.finished_status.must_equal :failed
        log.finished_stderr.must_equal "error one\nerror two\n"
      end

      it "times out slow containers" do
        log = TestContainerLog.new
        container = Container.new(image: "codeclimate/foo", name: "name", log: log, timeout: 0)

        # N.B. stubbing a private method is a Bad Idea, but it's the best I can
        # come up with here. Rather than invoke docker, we invoke a slow command
        # in order to trigger the timeout logic.
        container.stubs(:docker_run_command).returns(%w[ sleep 5 ])

        container.run

        log.timed_out?.must_equal true
      end
    end

    def stub_spawn(status: nil, out: StringIO.new, err: StringIO.new)
      pid = 42

      POSIX::Spawn.stubs(:popen4).returns([pid, nil, out, err])
      Process.stubs(:waitpid2).with(pid).returns([nil, status])

      return [pid, out, err]
    end

    def expect_spawn(args, status: nil, out: StringIO.new, err: StringIO.new)
      pid = 42

      POSIX::Spawn.expects(:popen4).with(*args).returns([pid, nil, out, err])
      Process.expects(:waitpid2).with(pid).returns([nil, status])

      return [pid, out, err]
    end
  end
end
