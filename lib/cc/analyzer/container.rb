require "posix/spawn"

module CC
  module Analyzer
    class Container
      ContainerData = Struct.new(
        :image,         # image used to create the container
        :name,          # name given to the container when created
        :duration,      # duration, for a finished event
        :status,        # status, for a finished event
        :stderr,        # stderr, for a finished event
      )
      BlankImage = Class.new(StandardError)

      DEFAULT_TIMEOUT = 15 * 60 # 15m

      def initialize(
        image:,
        name:,
        command: nil,
        listener: ContainerListener.new,
        timeout: DEFAULT_TIMEOUT
      )
        raise BlankImage if image.blank?
        @image = image
        @name = name
        @command = command
        @listener = listener
        @timeout = timeout

        @output_delimeter = "\n"
        @on_output = ->(*) { }

        @timed_out = false
        @stderr_io = StringIO.new
      end

      def on_output(delimeter = "\n", &block)
        @output_delimeter = delimeter
        @on_output = block
      end

      def run(options = [])
        started = Time.now
        @listener.started(container_data)

        pid, _, out, err = POSIX::Spawn.popen4(*docker_run_command(options))

        t_out = read_stdout(out)
        t_err = read_stderr(err)
        t_timeout = timeout_thread(pid)

        _, status = Process.waitpid2(pid)

        duration = ((Time.now - started) * 1000).round
        @listener.finished(container_data(duration: duration, status: status))

        t_timeout.kill
      ensure
        t_timeout.kill if t_timeout

        if @timed_out
          @listener.timed_out(container_data(duration: @timeout))
          t_out.kill if t_out
          t_err.kill if t_err
        else
          t_out.join if t_out
          t_err.join if t_err
        end
      end

      private

      def docker_run_command(options)
        [
          "docker", "run",
          "--rm",
          "--name", @name,
          options,
          @image,
          @command,
        ].flatten.compact
      end

      def read_stdout(out)
        Thread.new do
          out.each_line(@output_delimeter) do |chunk|
            output = chunk.chomp(@output_delimeter)

            @on_output.call(output)
          end
        end
      end

      def read_stderr(err)
        Thread.new do
          err.each_line { |line| @stderr_io.write(line) }
        end
      end

      def timeout_thread(pid)
        Thread.new do
          sleep @timeout
          @timed_out = true
          Process.kill("KILL", pid)
        end
      end

      def container_data(duration: nil, status: nil)
        ContainerData.new(
          @image,
          @name,
          duration,
          status,
          @stderr_io.string
        )
      end
    end
  end
end
