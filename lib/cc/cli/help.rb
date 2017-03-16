require "rainbow"

module CC
  module CLI
    class Help < Command
      ARGUMENT_LIST = "[command]".freeze
      SHORT_HELP = "Display help information.".freeze
      HELP = "#{SHORT_HELP}\n" \
        "\n" \
        "    no arguments   Show help summary for all commands.\n" \
        "    [command]      Show help for specific commands. Can be specified multiple times.".freeze

      def run
        if @args.any?
          @args.each do |command|
            show_help(command)
          end
        else
          show_help_summary
        end
      end

      private

      def show_help(command_name)
        if (command = Command[command_name])
          say "Usage: codeclimate #{command.synopsis}\n"
          say "\n"
          say "#{command.help}\n"
          say "\n\n"
        else
          say "Unknown command: #{command_name}"
        end
      end

      def show_help_summary
        short_helps =
          Command.all.sort_by(&:command_name).map do |command|
            [command.synopsis, command.short_help]
          end.compact.to_h

        longest_command_length = short_helps.keys.map(&:length).max

        say "Usage: codeclimate COMMAND ...\n\nAvailable commands:\n"
        short_helps.each do |command, help|
          say format("    %-#{longest_command_length}s    %s\n", command, help)
        end
      end
    end
  end
end
