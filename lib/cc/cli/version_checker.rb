module CC
  module CLI
    class VersionChecker
      include CC::CLI::Output

      VERSION_CHECK_TIMEOUT = 60 * 60 # 1 Hour in seconds
      DEFAULT_VERSIONS_URL = "https://versions.codeclimate.com".freeze

      def check
        print_new_version_message if outdated?
      rescue => error
        CLI.debug(error)
      end

      private

      def outdated?
        api_response["outdated"] == true
      end

      def latest_version
        api_response["latest"]
      end

      def print_new_version_message
        warn "A new version (v#{latest_version}) is available"
      end

      def api_response
        @api_response ||=
          begin
            JSON.parse(api_response_body)
          rescue JSON::ParserError => error
            CLI.debug(error)
            # We don't know so pretend all is peachy. We'll try again next time.
            {
              "latest" => version,
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
        CLI.debug(error)
        ""
      end

      def http_response
        @http_response ||=
          begin
            uri = URI.parse(ENV.fetch("CODECLIMATE_VERSIONS_URL", DEFAULT_VERSIONS_URL))
            uri.query = { version: version }.to_query
            Net::HTTP.start(uri.host, uri.port, open_timeout: 5, read_timeout: 5, ssl_timeout: 5, use_ssl: uri.scheme == "https") do |http|
              http.request_get(uri)
            end
          end
      end

      def version
        @version ||= Version.new.version
      end
    end
  end
end
