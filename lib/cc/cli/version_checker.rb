require "cc/cli/global_config"
require "cc/cli/global_cache"

module CC
  module CLI
    class VersionChecker
      include CC::CLI::Output

      VERSION_CHECK_TIMEOUT = 60 * 60 # 1 Hour in seconds
      DEFAULT_VERSIONS_URL = "https://versions.codeclimate.com".freeze

      def check
        return unless global_config.check_version? && version_check_is_due?

        print_new_version_message if outdated?

        global_config.save
      rescue => error
        CLI.logger.debug(error)
      end

      private

      def version_check_is_due?
        Time.now > global_cache.last_version_check + VERSION_CHECK_TIMEOUT
      end

      def outdated?
        api_response["outdated"]
      end

      def latest_version
        api_response["latest"]
      end

      def print_new_version_message
        warn "A new version (v#{latest_version}) is available. Upgrade instructions are available at: https://github.com/codeclimate/codeclimate#packages"
      end

      def api_response
        @api_response ||=
          begin
            cache! JSON.parse(api_response_body)
          rescue JSON::ParserError => error
            CLI.logger.debug(error)
            {
              "outdated" => false,
            }
          end
      end

      def api_response_body
        if http_response.is_a? Net::HTTPSuccess
          http_response.body
        else
          raise Net::HTTPFatalError.new("HTTP Error", http_response)
        end
      rescue Net::HTTPFatalError => error
        CLI.logger.debug(error)
        ""
      end

      def http_response
        @http_response ||=
          begin
            uri = URI.parse(ENV.fetch("CODECLIMATE_VERSIONS_URL", DEFAULT_VERSIONS_URL))
            uri.query = { version: version, uid: global_config.uuid }.to_query

            http = Net::HTTP.new(uri.host, uri.port)
            http.open_timeout = 5
            http.read_timeout = 5
            http.ssl_timeout = 5
            http.use_ssl = uri.scheme == "https"

            http.get(uri, "User-Agent" => user_agent)
          end
      end

      def cache!(data)
        global_cache.latest_version = data["latest"]
        global_cache.outdated = data["outdated"] == true
        global_cache.last_version_check = Time.now
        data
      end

      def version
        @version ||= Version.new.version
      end

      def user_agent
        "Code Climate CLI #{version}"
      end

      def global_config
        @global_config ||= GlobalConfig.new
      end

      def global_cache
        @global_cache ||= GlobalCache.new
      end

      def terminal
        @terminal ||= HighLine.new(nil, $stderr)
      end
    end
  end
end
