require "net/http"
require "rainbow"
require "active_support"
require "active_support/core_ext"

module CC
  module CLI
    class Runner
      TIMEOUT_CHECK = 60 * 60 # 1 Hour

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

      def version
        @_version ||= begin
          File.read(File.expand_path("../../../../VERSION", __FILE__)).sub('v', '')
        end
      end

      def last_check
        return { version: version, time: 0, outdated: false } unless has_config_file?("latest_version")
        load_latest_version
      end

      def config(file)
        dir = ENV.fetch('CODE_CLIMATE_CONFIG', File.expand_path(".code_climate", Dir.home))
        Dir.mkdir(dir, 0700) unless File.directory?(dir)
        File.join(dir, file)
      end

      def has_config_file?(name)
        File.exists?(config(name))
      end

      def load_latest_version
        YAML.load_file(config("latest_version"))
      end

      def save_latest_version!
        file = config("latest_version")
        File.write(file, latest_version.to_yaml)
      end

      def check_version
        return if should_not_check?

        since = Time.now.to_i - last_check["time"].to_i

        return if since < TIMEOUT_CHECK

        Timeout.timeout(5) do
          last_check["version"]  = latest_version["latest"]
          last_check["outdated"] = latest_version["outdated"] == true
        end

        needs_update_to_version(latest) if last_check["outdated"]

        save_latest_version!
      end

      def latest_version
        @_remote ||= begin
          url = ENV.fetch("CODE_CLIMATE_VERSIONS_URL", "https://versions.codeclimate.com")
          uri = URI.parse(url)

          values = { version: version, uname: `uname -a` }
          uri.query = values.to_query

          resp = Net::HTTP.get_response(uri)
          JSON.parse(resp.body).merge("time" => Time.now.to_i)
        end
      end

      def needs_update_to_version(latest)
        warn Rainbow("~~~ Needs update to version #{latest}, currently #{version} ~~~").red
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
