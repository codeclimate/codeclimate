require "net/http"
require "active_support"
require "active_support/core_ext"

module CC
  module CLI
    class Runner
      def self.run(argv)
        new(argv).run
      rescue => ex
        $stderr.puts("error: (#{ex.class}) #{ex.message}")

        CLI.debug("backtrace: #{ex.backtrace.join("\n\t")}")
      end

      def initialize(args)
        @args = args
      end

      def run
        check_version

        if command_class
          command = command_class.new(command_arguments)
          command.execute
        else
          command_not_found
        end
      end

      def should_not_check?
        false
      end

      def is_outdated?(version)
        latest_version = version.sub('v', '')
        current_version = File.read(File.expand_path("../../../../VERSION", __FILE__)).sub('v', '')

        Gem::Version.new(latest_version) > Gem::Version.new(current_version)
      end

      def check_version
        return if should_not_check?

        Timeout.timeout(5) do
          url = ENV.fetch("CODE_CLIMATE_VERSIONS_URL", "versions.codeclimate.com")
          uri = URI.parse(url)
          resp = Net::HTTP.get_response(uri)
          json = JSON.parse(resp.body)
          latest_version = json["version"]

          warn "Needs update" if is_outdated?(latest_version)
        end
      end

      def command_not_found
        $stderr.puts "unknown command #{command}"
        exit 1
      end

      def command_class
        command_const = Command[command]
        if command_const.abstract?
          nil
        else
          command_const
        end
      rescue NameError
        nil
      end

      def command_arguments
        @args[1..-1]
      end

      def command
        command_name = @args.first
        case command_name
        when nil, "-h", "-?", "--help"
          "help"
        when "-v", "--version"
          "version"
        else
          command_name
        end
      end
    end
  end
end
