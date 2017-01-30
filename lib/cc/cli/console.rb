module CC
  module CLI
    class Console < Command
      SHORT_HELP = "Open a ruby console for the CLI. Useful for developing against the CLI.".freeze

      def run
        require "pry"
        binding.pry(quiet: true, prompt: Pry::SIMPLE_PROMPT, output: $stdout)
      end
    end
  end
end
