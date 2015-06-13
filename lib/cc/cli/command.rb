require "highline"
require "active_support"
require "active_support/core_ext"

module CC
  module CLI
    class Command

      def initialize(args = [])
        @args = args
      end

      def run
        $stderr.puts "unknown command #{self.class.name.split('::').last.underscore}"
      end

      def self.command_name
        name[/[^:]*$/].split(/(?=[A-Z])/).map(&:downcase).join('-')
      end

      def execute
        run
      end

      def say(message)
        terminal.say message
      end

    private

      def terminal
        @terminal ||= HighLine.new($stdin, $stdout)
      end
    end
  end
end
