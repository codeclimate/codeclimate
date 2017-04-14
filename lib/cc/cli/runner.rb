require "active_support"
require "active_support/core_ext"
require "cc/cli/version_checker"

module CC
  module CLI
    class Runner
      def self.run(argv)
        new(argv).run
      rescue => ex
        $stderr.puts("error: (#{ex.class}) #{ex.message}")
        CLI.logger.debug("backtrace: #{ex.backtrace.join("\n\t")}")
        exit 1
      end

      def initialize(args)
        @args = args
      end

      def run
        VersionChecker.new.check if check_version?

        if command_class
          command = command_class.new(command_arguments)
          command.execute
        else
          command_not_found
        end
      end

      def command_not_found
        $stderr.puts "unknown command #{command}"
        exit 1
      end

      def command_class
        command_const = Command[command]
        if command_const.abstract?
          nil
        else
          command_const
        end
      rescue NameError
        nil
      end

      def command_arguments
        Array(@args[1..-1])
      end

      def command
        command_name = @args.first
        case command_name
        when nil, "-h", "-?", "--help"
          "help"
        when "-v", "--version"
          "version"
        else
          command_name
        end
      end

      private

      def check_version?
        if ARGV.first == "--no-check-version"
          ARGV.shift
          false
        else
          true
        end
      end
    end
  end
end
