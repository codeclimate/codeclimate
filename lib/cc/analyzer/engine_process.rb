require "timeout"
require "open4"

module CC
  module Analyzer
    class EngineProcess
      attr_reader :status
      attr_reader :pid

      def initialize(engine_name, debug = false)
        @engine_name = engine_name
        @debug = debug
        @pid = nil
        @status = nil

        @stdin = nil
        @stdout = nil
        @stderr = nil

        @out = ""
        @err = ""
      end

      def run
        execute
        check_for_failure

        yield self

        kill
        check_for_failure
      rescue Object
        kill
        raise
      ensure
        force_close_streams
      end

      def check_for_failure
        if failed?
          $stderr.puts "analyzer failed with exit code: #{exit_code.inspect}"
          exit 1
        end
      end

      def exit_code
        @status && @status.exitstatus
      end

      def failed?
        !alive? && !@status.success?
      end

      def wait_for_url
        url = nil

        Timeout.timeout(5) do
          url = @out.split.first while url.blank?
        end

        url
      end

      def alive?
        if @status
          false
        else
          _, @status = Process.waitpid2(@pid, Process::WNOHANG)
          !@status
        end
      end

      def execute
        @pid, @stdin, @stdout, @stderr = Open4.popen4(command)
        @stdin.close
        start_output_processing_thread
      end

      def kill
        kill_child_and_wait
        force_close_streams
        @status
      end

    private

      def start_output_processing_thread
        Thread.new do
          readers = [@stdout, @stderr]

          while readers.any?
            ready = IO.select(readers, [], readers)

            ready[0].each do |fd|
              line_printer = (fd == @stdout) ? out_printer : err_printer
              stream       = (fd == @stdout) ? @out : @err

              begin
                data = fd.readpartial(32 * 1024)
                line_printer << data
                stream << data
              rescue Errno::EAGAIN, Errno::EINTR
              rescue EOFError
                readers.delete(fd)
                line_printer.close
                fd.close
              end
            end
          end
        end
      end

      def out_printer
        @out_printer ||= if @debug
          LinePrinter.new($stdout, "stdout: ")
        else
          LinePrinter::Null.new
        end
      end

      def err_printer
        @err_printer ||= if @debug
          LinePrinter.new($stdout, "stderr: ")
        else
          LinePrinter::Null.new
        end
      end

      def kill_child_and_wait
        if @status.nil?
          ::Process.kill("TERM", @pid)
          _, @status = Process.waitpid2(@pid)
        end
      end

      def command
        "codeclimate-#{@engine_name}"
      end

      def force_close_streams
        [@stdin, @stderr, @stdout].each { |fd| fd.close rescue nil }
      end

    end
  end
end
