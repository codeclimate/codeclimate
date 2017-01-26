require "rainbow"

module CC
  module CLI
    class Help < Command
      ARGUMENT_LIST = "[commad]"
      SHORT_HELP = "Show help."
      HELP = "#{SHORT_HELP}\n" \
        "\n" \
        "    no arguments   Show help summary for all commands.\n" \
        "    [command]      Show help for specific commands. Can be scpecified multiple times."

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
        command = Command[command_name]
        say "Usage: #{$PROGRAM_NAME} #{command.synopsis}\n"
        say "\n"
        say "#{command.help}\n"
        say "\n\n"
      end

      def show_help_summary
        short_helps =
          Command.all
          .sort_by(&:command_name)
          .map do |command|
            [
              command.synopsis,
              command.short_help
            ]
          end.compact.to_h

        longest_command_length = short_helps.keys.map(&:length).max

        say "Usage: codeclimate COMMAND ...\n\nAvailable commands:\n"
        short_helps.each do |command, help|
          say format("    %-#{longest_command_length}s    %s\n", command, help)
        end
      end

      def underline(string)
        Rainbow.new.wrap(string).underline
      end
    end
  end
end
