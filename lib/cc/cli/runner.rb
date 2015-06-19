require "active_support"
require "active_support/core_ext"
require "safe_yaml"

module CC
  module CLI
    class Runner

      def self.run(argv)
        new(argv).run
      rescue => ex
        $stderr.puts("error: (#{ex.class}) #{ex.message}")

        if ENV["CODECLIMATE_DEBUG"]
          $stderr.puts("backtrace: #{ex.backtrace.join("\n\t")}")
        end
      end

      def initialize(args)
        SafeYAML::OPTIONS[:default_mode] = :safe

        @args = args
      end

      def run
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
        CLI.const_get(command_name)
      rescue NameError
        nil
      end

      def command_name
        case command
        when nil, '-h', '-?', '--help' then 'Help'
        when '-v', '--version'         then 'Version'
        else command.sub(":", "::").underscore.camelize
        end
      end

      def command_arguments
        @args[1..-1]
      end

      def command
        @args.first
      end

    end
  end
end
