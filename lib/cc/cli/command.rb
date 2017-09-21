require "highline"
require "active_support"
require "active_support/core_ext"
require "rainbow"
require "cc/cli/output"

module CC
  module CLI
    class Command
      include CC::CLI::Output

      CODECLIMATE_YAML = ".codeclimate.yml".freeze
      NAMESPACE = name.split("::")[0..-2].join("::").freeze

      def self.abstract!
        @abstract = true
      end

      def self.abstract?
        @abstract == true
      end

      def self.all
        @@subclasses.reject(&:abstract?)
      end

      def self.[](name)
        all.find { |command| command.name == "#{NAMESPACE}::#{name}" || command.command_name == name }
      end

      # rubocop: disable Style/ClassVars
      def self.inherited(subclass)
        @@subclasses ||= []
        @@subclasses << subclass
      end
      # rubocop: enable Style/ClassVars

      def self.synopsis
        "#{command_name} #{self::ARGUMENT_LIST if const_defined?(:ARGUMENT_LIST)}".strip
      end

      def self.short_help
        if const_defined? :SHORT_HELP
          self::SHORT_HELP
        else
          ""
        end
      end

      def self.help
        if const_defined? :HELP
          self::HELP
        else
          short_help
        end
      end

      def initialize(args = [])
        @args = args
      end

      def run
        $stderr.puts "unknown command #{self.class.name.split("::").last.underscore}"
      end

      def self.command_name
        name.gsub(/^#{NAMESPACE}::/, "").split("::").map do |part|
          part.split(/(?=[A-Z])/).map(&:downcase).join("-")
        end.join(":")
      end

      def execute
        run
      end

      private

      def filesystem
        @filesystem ||= CC::Analyzer::Filesystem.new(
          CC::Analyzer::MountedPath.code.container_path,
        )
      end
    end
  end
end
