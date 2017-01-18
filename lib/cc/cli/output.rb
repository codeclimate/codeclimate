module CC
  module CLI
    module Output
      def success(message)
        terminal.say colorize(message, :green)
      end

      def say(message)
        terminal.say message
      end

      def warn(message)
        terminal.say colorize("WARNING: #{message}", :yellow)
      end

      def fatal(message)
        $stderr.puts colorize(message, :red)
        exit 1
      end

      def colorize(string, *args)
        rainbow.wrap(string).color(*args)
      end

      def rainbow
        @rainbow ||= Rainbow.new
      end

      def terminal
        @terminal ||= HighLine.new($stdin, $stdout)
      end
    end
  end
end
