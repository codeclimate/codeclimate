require "highline"
require "active_support"
require "active_support/core_ext"
require "rainbow"

module CC
  module CLI
    class Command
      CODECLIMATE_YAML = ".codeclimate.yml".freeze
      InvalidOption = Class.new(StandardError)

      def initialize(args = [])
        @args = args
        @force = false
      end

      def run
        $stderr.puts "unknown command #{self.class.name.split('::').last.underscore}"
      end

      def self.command_name
        name[/[^:]*$/].split(/(?=[A-Z])/).map(&:downcase).join("-")
      end

      def process_args
        while (arg = @args.shift)
          case arg
          when "-f", "--f", "--force"
            @force = true
          else
            raise InvalidOption, "option #{arg} not found. Try running codeclimate --help for a list of valid commands."
          end
        end
      end

      def execute
        process_args
        run
      end

      def success(message)
        terminal.say colorize(message, :green)
      end

      def say(message)
        terminal.say message
      end

      def warn(message)
        terminal.say(colorize("WARNING: #{message}", :yellow))
      end

      def fatal(message)
        $stderr.puts colorize(message, :red)
        exit 1
      end

      def require_codeclimate_yml
        unless filesystem.exist?(CODECLIMATE_YAML)
          fatal("No '.codeclimate.yml' file found. Run 'codeclimate init' to generate a config file.")
        end
      end

      private

      attr_reader :force

      def colorize(string, *args)
        rainbow.wrap(string).color(*args)
      end

      def rainbow
        @rainbow ||= Rainbow.new
      end

      def filesystem
        @filesystem ||= CC::Analyzer::Filesystem.new(ENV["FILESYSTEM_DIR"])
      end

      def terminal
        @terminal ||= HighLine.new($stdin, $stdout)
      end

      def engine_registry
        @engine_registry ||= CC::Analyzer::EngineRegistry.new
      end
    end
  end
end
