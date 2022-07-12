require "cc/analyzer/container/result"
require "open3"

module CC
  module Analyzer
    #
    # Running an abstract docker container
    #
    # Input:
    #   - image
    #   - name
    #   - command (Optional)
    #
    # Output:
    #   - Result
    #     - exit_status
    #     - timed_out?
    #     - duration
    #     - maximum_output_exceeded?
    #     - output_byte_count
    #     - stderr
    #
    # Never raises (unless broken)
    #
    class Container
      DEFAULT_TIMEOUT = 15 * 60 # 15m
      DEFAULT_MAXIMUM_OUTPUT_BYTES = 500_000_000

      def initialize(image:, name:, command: nil)
        @image = image
        @name = name
        @command = command
        @timed_out = false
        @maximum_output_exceeded = false
        @stdout_io = StringIO.new
        @stderr_io = StringIO.new
        @output_byte_count = 0
        @counter_mutex = Mutex.new

        # By default accumulate and include stdout in result
        @output_delimeter = "\n"
        @on_output = ->(output) { @stdout_io.puts(output) }
      end

      def on_output(delimeter = "\n", &block)
        @output_delimeter = delimeter
        @on_output = block
      end

      def run(options = [])
        started = Time.now

        command = docker_run_command(options)
        Analyzer.logger.debug("docker run: #{command.inspect}")
        _, out, err, @t_wait = Open3.popen3(*command)

        @t_out = read_stdout(out)
        @t_err = read_stderr(err)
        t_timeout = timeout_thread

        # Calling @t_wait.value waits the termination of the process / engine
        @status = @t_wait.value

        # blocks until all readers are done. they're still governed by the
        # timeout thread at this point. if we hit the timeout while processing
        # output, the threads will be Thread#killed as part of #stop and this
        # will unblock with the correct value in @timed_out
        [@t_out, @t_err].each(&:join)

        duration =
          if @timed_out
            timeout * 1000
          else
            ((Time.now - started) * 1000).round
          end

        Result.new(
          container_name: @name,
          duration: duration,
          exit_status: @status&.exitstatus,
          maximum_output_exceeded: @maximum_output_exceeded,
          output_byte_count: output_byte_count,
          stderr: @stderr_io.string,
          stdout: @stdout_io.string,
          timed_out: @timed_out,
        )
      ensure
        kill_reader_threads
        t_timeout&.kill
      end

      def stop(message = nil)
        reap_running_container(message)
        kill_reader_threads
        # Manually killing the process otherwise a run-away container
        # could still block here forever if the docker-kill/wait is not
        # successful
        kill_wait_thread
      end

      private

      attr_reader :output_byte_count, :counter_mutex

      def docker_run_command(options)
        [
          "docker", "run",
          "--name", @name,
          options,
          @image,
          @command
        ].flatten.compact
      end

      def read_stdout(out)
        Thread.new do
          out.each_line(@output_delimeter) do |chunk|
            output = chunk.chomp(@output_delimeter)

            Analyzer.logger.debug("engine stdout: #{output}")
            @on_output.call(output)
            check_output_bytes(output.bytesize)
          end
        ensure
          out.close
        end
      end

      def read_stderr(err)
        Thread.new do
          err.each_line do |line|
            Analyzer.logger.debug("engine stderr: #{line.chomp}")
            @stderr_io.write(line)
            check_output_bytes(line.bytesize)
          end
        ensure
          err.close
        end
      end

      def timeout_thread
        Thread.new do
          # Doing one long `sleep timeout` seems to fail sometimes, so
          # we do a series of short timeouts before exiting
          start_time = Time.now
          loop do
            sleep 10
            duration = Time.now - start_time
            break if duration >= timeout
          end

          @timed_out = true
          stop("timed out")
        end.run
      end

      def check_output_bytes(last_read_byte_count)
        counter_mutex.synchronize do
          @output_byte_count += last_read_byte_count
        end

        if output_byte_count > maximum_output_bytes
          @maximum_output_exceeded = true
          stop("maximum output exceeded")
        end
      end

      def kill_reader_threads
        @t_out&.kill
        @t_err&.kill
      end

      def kill_wait_thread
        @t_wait&.kill
      end

      def reap_running_container(message)
        Analyzer.logger.warn("killing container name=#{@name} message=#{message.inspect}")
        Timeout.timeout(2.minutes.to_i) do
          Kernel.system("docker", "kill", @name, [:out, :err] => File::NULL)
          Kernel.system("docker", "wait", @name, [:out, :err] => File::NULL)
        end
      rescue Timeout::Error
        Analyzer.logger.error("unable to kill container name=#{@name} message=#{message.inspect}")
        Analyzer.statsd.increment("container.zombie")
        Analyzer.statsd.increment("container.zombie.#{metric_name}") if metric_name
      end

      def timeout
        ENV.fetch("CONTAINER_TIMEOUT_SECONDS", DEFAULT_TIMEOUT).to_i
      end

      def maximum_output_bytes
        ENV.fetch("CONTAINER_MAXIMUM_OUTPUT_BYTES", DEFAULT_MAXIMUM_OUTPUT_BYTES).to_i
      end

      def metric_name
        if /^cc-engines-(?<engine>[^-]+)-(?<channel>[^-]+)-/ =~ @name
          "engine.#{engine}.#{channel}"
        elsif /^builder-(?<action>[^-]+)-/ =~ @name
          "builder.#{action}"
        end
      end
    end
  end
end
