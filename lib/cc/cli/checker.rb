module CC
  module CLI
    module Checker
      include CC::CLI::Output

      TIMEOUT_CHECK = 60 * 60 # 1 Hour

      def last_check
        return { version: version, time: 0, outdated: false } unless has_config_file?("latest_version")
        load_latest_version
      end

      def config(file)
        dir = ENV.fetch("CODE_CLIMATE_CONFIG", File.expand_path(".code_climate", Dir.home))
        Dir.mkdir(dir, 0o700) unless File.directory?(dir)
        File.join(dir, file)
      end

      def has_config_file?(name)
        File.exist?(config(name))
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

        update_last_check

        needs_update_to_version if last_check["outdated"]

        save_latest_version!
      rescue Timeout::Error, JSON::ParserError, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED => ex
        CLI.debug(ex)
      end

      def should_not_check?
        false
      end

      def version
        @_version ||= begin
          File.read(File.expand_path("../../../../VERSION", __FILE__)).sub("v", "")
        end
      end

      def update_last_check
        Timeout.timeout(5) do
          last_check["latest"] = latest_version["latest"]
          last_check["outdated"] = latest_version["outdated"] == true
        end
      end

      def latest_version
        @_remote ||= begin
          url = ENV.fetch("CODE_CLIMATE_VERSIONS_URL", "https://versions.codeclimate.com")
          uri = URI.parse(url)

          CLI.debug("Checking #{url} for latest version")

          uri.query = { version: version, uname: `uname -a` }.to_query
          resp = Net::HTTP.get_response(uri)

          JSON.parse(resp.body).merge("time" => Time.now.to_i)
        end
      end

      def needs_update_to_version
        warn "A new version version (v#{last_check["latest"]}) is available"
      end
    end
  end
end
