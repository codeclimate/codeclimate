module CC
  module CLI
    class Help < Command

      def run
        say "Usage: codeclimate COMMAND ...\n\nAvailable commands:\n\n"
        commands.each do |command|
          say "\t#{command.command_name}"
        end
      end

      def commands
        CLI.commands.sort_by(&:command_name)
      end

    end
  end
end
