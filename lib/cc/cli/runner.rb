require "active_support"
require "active_support/core_ext"

module CC
  module CLI
    class Runner

      def self.run(argv)
        new(argv).run
      end

      def initialize(args)
        @args = args
      end

      def run
        if command_class
          command = command_class.new
          command.execute
        else
          command_not_found
        end
      end

      def command_not_found
        $stderr.puts "unknown command #{command_name}"
        exit 1
      end

      def command_class
        CLI.const_get(command_name)
      rescue NameError
        nil
      end

      def command_name
        case @args.first
        when nil, '-h', '-?', '--help' then 'Help'
        when '-v', '--version'         then 'Version'
        else @args.first.underscore.camelize
        end
      end

    end
  end
end
