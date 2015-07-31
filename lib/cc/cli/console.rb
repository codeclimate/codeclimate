module CC
  module CLI
    class Console < Command
      def run
        require "pry"
        binding.pry(quiet: true, prompt: Pry::SIMPLE_PROMPT, output: $stdout)
      end
    end
  end
end
