require "posix/spawn"
require "securerandom"

module CC
  module Analyzer
    class Engine
      attr_reader :name

      TIMEOUT = 15 * 60 # 15m

      def initialize(name, metadata, code_path, config_path, label)
        @name = name
        @metadata = metadata
        @code_path = code_path
        @config_path = config_path
        @label = label.to_s
      end

      def run(stdout_io, stderr_io = StringIO.new)
        pid, _, out, err = POSIX::Spawn.popen4(*docker_run_command)
        engine_running = true

        t_out = Thread.new do
          out.each_line("\0") do |chunk|
            stdout_io.write(chunk.chomp("\0"))
          end
        end

        t_err = Thread.new do
          err.each_line do |line|
            if stderr_io
              stderr_io.write(line)
            end
          end
        end

        Thread.new do
          sleep TIMEOUT

          if engine_running
            Thread.current.abort_on_exception = true
            run_command("docker kill #{container_name}")

            stdout_io.failed("Execution timed out")
          end
        end

        pid, status = Process.waitpid2(pid)
        engine_running = false

        if status.exitstatus > 0
          stdout_io.failed(stderr_io.string)
        end
      ensure
        t_out.join if t_out
        t_err.join if t_err
      end

      private

      def container_name
        @container_name ||= "cc-engines-#{name}-#{SecureRandom.uuid}"
      end

      def docker_run_command
        [
          "docker", "run",
          "--rm",
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=#{@label}",
          "--name", container_name,
          "--memory", 512_000_000.to_s, # bytes
          "--memory-swap", "-1",
          "--net", "none",
          "--volume", "#{@code_path}:/code:ro",
          "--volume", "#{@config_path}:/config.json:ro",
          @metadata["image_name"],
          @metadata["command"], # String or Array
        ].flatten.compact
      end

      def run_command(command)
        spawn = POSIX::Spawn::Child.new(command)

        if spawn.status.exitstatus > 0
          raise CommandFailure, "command '#{command}' failed with status #{spawn.status.exitstatus} and output #{spawn.err}"
        end
      end

      CommandFailure = Class.new(StandardError)
    end
  end
end
