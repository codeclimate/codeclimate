require "posix/spawn"
require "securerandom"

module CC
  module Analyzer
    class Engine
      attr_reader :name

      TIMEOUT = 15 * 60 # 15m

      def initialize(name, metadata, code_path, config, label)
        @name = name
        @metadata = metadata
        @code_path = code_path
        @config = config
        @label = label.to_s
      end

      def run(stdout_io:, stderr_io: StringIO.new, container_log: NullContainerLog.new)
        container_log.started(@metadata["image"])

        timed_out = false
        pid, _, out, err = POSIX::Spawn.popen4(*docker_run_command)
        Analyzer.statsd.increment("cli.engines.started")

        t_out = Thread.new do
          out.each_line("\0") do |chunk|
            output = chunk.chomp("\0")

            unless output_filter.filter?(output)
              stdout_io.write(output)
            end
          end
        end

        t_err = Thread.new do
          err.each_line do |line|
            if stderr_io
              stderr_io.write(line)
            end
          end
        end

        t_timeout = Thread.new do
          sleep TIMEOUT
          run_command("docker kill #{container_name} || true")
          timed_out = true
        end

        pid, status = Process.waitpid2(pid)
        t_timeout.kill

        Analyzer.statsd.increment("cli.engines.finished")

        if timed_out
          Analyzer.statsd.increment("cli.engines.result.error")
          Analyzer.statsd.increment("cli.engines.result.error.timeout")
          Analyzer.statsd.increment("cli.engines.names.#{name}.result.error")
          Analyzer.statsd.increment("cli.engines.names.#{name}.result.error.timeout")
          container_log.timed_out
          raise EngineTimeout, "engine #{name} ran past #{TIMEOUT} seconds and was killed"
        end

        container_log.finished(status, stderr_io.string)

        if status.success?
          Analyzer.statsd.increment("cli.engines.names.#{name}.result.success")
          Analyzer.statsd.increment("cli.engines.result.success")
        else
          Analyzer.statsd.increment("cli.engines.names.#{name}.result.error")
          Analyzer.statsd.increment("cli.engines.result.error")
          raise EngineFailure, "engine #{name} failed with status #{status.exitstatus} and stderr \n#{stderr_io.string}"
        end
      ensure
        t_timeout.kill if t_timeout

        if timed_out
          t_out.kill if t_out
          t_err.kill if t_err
        else
          t_out.join if t_out
          t_err.join if t_err
        end
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
          "--volume", "#{config_file}:/config.json:ro",
          "--user", "9000:9000",
          @metadata["image"],
          @metadata["command"], # String or Array
        ].flatten.compact
      end

      def config_file
        path = File.join("/tmp/cc", SecureRandom.uuid)
        File.write(path, @config.to_json)
        path
      end

      def run_command(command)
        spawn = POSIX::Spawn::Child.new(command)

        unless spawn.status.success?
          raise CommandFailure, "command '#{command}' failed with status #{spawn.status.exitstatus} and output #{spawn.err}"
        end
      end

      def output_filter
        @output_filter ||= EngineOutputFilter.new(@config)
      end

      CommandFailure = Class.new(StandardError)
      EngineFailure = Class.new(StandardError)
      EngineTimeout = Class.new(StandardError)
    end
  end
end
