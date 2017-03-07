require "cc/cli/global_config"
require "cc/cli/global_cache"

module CC
  module CLI
    class VersionChecker
      include CC::CLI::Output

      VERSION_CHECK_TIMEOUT = 60 * 60 # 1 Hour in seconds
      DEFAULT_VERSIONS_URL = "https://versions.codeclimate.com".freeze

      def check
        return unless global_config.check_version?

        print_new_version_message if outdated?
      rescue => error
        CLI.debug(error)
      end

      private

      def version_check_is_due?
        Time.now > global_cache.last_version_check + VERSION_CHECK_TIMEOUT
      end

      def outdated?
        if version_check_is_due?
          api_response["outdated"] == true
        else
          global_cache.outdated?
        end
      end

      def latest_version
        if version_check_is_due?
          api_response["latest"]
        else
          global_cache.latest_version
        end
      end

      def print_new_version_message
        warn "A new version (v#{latest_version}) is available"
      end

      def api_response
        @api_response ||=
          begin
            cache! JSON.parse(api_response_body)
          rescue JSON::ParserError => error
            CLI.debug(error)
            # We don't know so use cached values or pretend all is peachy. We'll
            # try again next time.
            {
              "latest" => global_cache.latest_version || version,
              "outdated" => global_cache.outdated || false,
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
        CLI.debug(error)
        ""
      end

      def http_response
        @http_response ||=
          begin
            uri = URI.parse(ENV.fetch("CODECLIMATE_VERSIONS_URL", DEFAULT_VERSIONS_URL))
            uri.query = { version: version, uid: global_config.uuid }.to_query
            Net::HTTP.start(uri.host, uri.port, open_timeout: 5, read_timeout: 5, ssl_timeout: 5, use_ssl: uri.scheme == "https") do |http|
              http.request_get(uri)
            end
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

      def global_config
        @global_config ||= GlobalConfig.new
      end

      def global_cache
        @global_cache ||= GlobalCache.new
      end
    end
  end
end
