module CC
  module Analyzer
    class Container
      TIMEOUT = 15 * 60 # 15m

      def initialize(image, command = nil, log = nil)
        @image = image
        @command = command
        @log = log || NullContainerLog.new

        @output_delimeter = "\n"
        @on_output = ->(*) { }

        @timed_out = false
        @stderr_io = StringIO.new
      end

      def on_output(delimeter = "\n", &block)
        @output_delimeter = delimeter
        @on_output = block
      end

      def run(options)
        @log.started(@image)

        pid, _, out, err = POSIX::Spawn.popen4(*docker_run_command(options))

        t_out = read_stdout(out)
        t_err = read_stderr(err)
        t_timeout = timeout_thread(pid)

        _, status = Process.waitpid2(pid)

        @log.finished(status, @stderr_io.string)

        t_timeout.kill
      ensure
        t_timeout.kill if t_timeout

        if @timed_out
          @log.timed_out
          t_out.kill if t_out
          t_err.kill if t_err
        else
          t_out.join if t_out
          t_err.join if t_err
        end
      end

      private

      def docker_run_command(options)
        ["docker run --rm", *options, @image @command].compact
      end


      def read_stdout(out)
        Thread.new do
          out.each_line(@output_delimeter, &@on_output)
        end
      end

      def read_stderr(err)
        Thread.new do
          err.each_line { |line| stderr_io.write(line) }
        end
      end

      def timeout_thread(pid)
        Thread.new do
          sleep TIMEOUT
          Process.kill("KILL", pid)
          @timed_out = true
        end
      end
    end
  end
end
