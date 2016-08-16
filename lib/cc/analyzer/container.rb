require "posix/spawn"
require "thread"

module CC
  module Analyzer
    class Container
      ContainerData = Struct.new(
        :image, # image used to create the container
        :name, # name given to the container when created
        :duration, # duration, for a finished event
        :status, # status, for a finished event
        :stderr, # stderr, for a finished event
      )
      ImageRequired = Class.new(StandardError)
      Result = Struct.new(
        :exit_status,
        :timed_out?,
        :duration,
        :maximum_output_exceeded?,
        :output_byte_count,
        :stderr,
      )

      DEFAULT_TIMEOUT = 15 * 60 # 15m
      DEFAULT_MAXIMUM_OUTPUT_BYTES = 500_000_000

      def initialize(image:, name:, command: nil, listener: ContainerListener.new)
        raise ImageRequired if image.blank?
        @image = image
        @name = name
        @command = command
        @listener = listener
        @output_delimeter = "\n"
        @on_output = ->(*) {}
        @timed_out = false
        @maximum_output_exceeded = false
        @stderr_io = StringIO.new
        @output_byte_count = 0
        @counter_mutex = Mutex.new
      end

      def on_output(delimeter = "\n", &block)
        @output_delimeter = delimeter
        @on_output = block
      end

      def run(options = [])
        started = Time.now
        @listener.started(container_data)

        command = docker_run_command(options)
        CLI.debug("docker run: #{command.inspect}")
        pid, _, out, err = POSIX::Spawn.popen4(*command)

        @t_out = read_stdout(out)
        @t_err = read_stderr(err)
        t_timeout = timeout_thread

        # blocks until the engine stops. this is put in a thread so that we can
        # explicitly abort it as part of #stop. otherwise a run-away container
        # could still block here forever if the docker-kill/wait is not
        # successful. there may still be stdout in flight if it was being
        # produced more quickly than consumed.
        @t_wait = Thread.new { _, @status = Process.waitpid2(pid) }
        @t_wait.join

        # blocks until all readers are done. they're still governed by the
        # timeout thread at this point. if we hit the timeout while processing
        # output, the threads will be Thread#killed as part of #stop and this
        # will unblock with the correct value in @timed_out
        [@t_out, @t_err].each(&:join)

        if @timed_out
          duration = timeout * 1000
          @listener.timed_out(container_data(duration: duration))
        else
          duration = ((Time.now - started) * 1000).round
          @listener.finished(container_data(duration: duration, status: @status))
        end

        Result.new(
          @status && @status.exitstatus,
          @timed_out,
          duration,
          @maximum_output_exceeded,
          output_byte_count,
          @stderr_io.string,
        )
      ensure
        kill_reader_threads
        t_timeout.kill if t_timeout
      end

      def stop(message = nil)
        reap_running_container(message)
        kill_reader_threads
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
          begin
            out.each_line(@output_delimeter) do |chunk|
              output = chunk.chomp(@output_delimeter)

              @on_output.call(output)
              check_output_bytes(output.bytesize)
            end
          ensure
            out.close
          end
        end
      end

      def read_stderr(err)
        Thread.new do
          begin
            err.each_line do |line|
              @stderr_io.write(line)
              check_output_bytes(line.bytesize)
            end
          ensure
            err.close
          end
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

      def container_data(duration: nil, status: nil)
        ContainerData.new(@image, @name, duration, status, @stderr_io.string)
      end

      def kill_reader_threads
        @t_out.kill if @t_out
        @t_err.kill if @t_err
      end

      def kill_wait_thread
        @t_wait.kill if @t_wait
      end

      def reap_running_container(message)
        Analyzer.logger.warn("killing container name=#{@name} message=#{message.inspect}")
        POSIX::Spawn::Child.new("docker", "kill", @name, timeout: 2.minutes)
        POSIX::Spawn::Child.new("docker", "wait", @name, timeout: 2.minutes)
      rescue POSIX::Spawn::TimeoutExceeded
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
