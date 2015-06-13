require "highline"

module CC
  module CLI
    class Command

      def initialize(args = [])
        @args = args
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
