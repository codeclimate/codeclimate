module CC
  module CLI
    class Help < Command

      COMMANDS = [
        'analyze [-f format] [path]',
        'console',
        'engines:list',
        'help',
        'init',
        'validate-config',
        'version'
      ].freeze

      def run
        say "Usage: codeclimate COMMAND ...\n\nAvailable commands:\n"
        COMMANDS.each do |command|
          say "    #{command}"
        end
      end
    end
  end
end
