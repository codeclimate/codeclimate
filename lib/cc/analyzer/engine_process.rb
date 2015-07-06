require "posix/spawn"

module CC
  module Analyzer
    class EngineProcess
      # As per the SPEC, an engine itself has 15 minutes to run.
      ENGINE_TIMEOUT = 15 * 60

      # We allow an additional 5 for our own processing. Some engines choose to
      # output everything at once at the end so this processing can take some
      # time and cause builder processes to appear hung if we don't enforce a
      # timeout for the overall operation as well as runnning the engine.
      TIMEOUT = ENGINE_TIMEOUT + 5 * 60


      def initialize(engine, stdout_io, stderr_io = StringIO.new)
        @engine = engine
        @stdout_io = stdout_io
        @stderr_io = stderr_io

        EngineTimeout.runtime_message = "engine #{@engine.name} ran past #{ENGINE_TIMEOUT} seconds and was killed"
      end

      def run
        Timeout.timeout(TIMEOUT) do
          status = run_engine

          if status.success?
            increment("result.success")
          else
            increment("result.error")
            fail EngineFailure, "engine #{@engine.name} failed with status #{status.exitstatus} and stderr #{@stderr_io.string.inspect}"
          end
        end
      end

      private

      def run_engine
        # ensure correct lexical scope
        pid = read_out = read_err = nil

        status = Timeout.timeout(ENGINE_TIMEOUT, EngineTimeout) do
          pid, stdin, stdout, stderr = POSIX::Spawn.popen4(*@engine.command)
          stdin.close

          increment("started")

          read_out = Thread.new do
            stdout.each_line("\0") do |chunk|
              @stdout_io.write(chunk.chomp("\0"))
            end
          end

          read_err = Thread.new do
            stderr.each_line do |line|
              @stderr_io.write(line)
            end
          end

          Process.waitpid2(pid)[1]
        end

        read_out.join
        read_err.join

        status
      rescue
        abort_process(pid) if pid
        read_out.kill if read_out
        read_err.kill if read_err
        raise
      end

      def abort_process(pid)
        Process.kill("KILL", pid)
        Process.waitpid(pid)
        increment("aborted")
      rescue Errno::ECHILD
        # process was already cleaned up
      end

      def increment(metric)
        Analyzer.statsd.increment("cli.engines.names.#{@engine.name}.#{metric}")
        Analyzer.statsd.increment("cli.engines.#{metric}")
      end

      EngineFailure = Class.new(StandardError)

      class EngineTimeout < StandardError
        class << self
          attr_accessor :runtime_message
        end

        def initialize(*)
          super(self.class.runtime_message)
        end
      end
    end
  end
end
