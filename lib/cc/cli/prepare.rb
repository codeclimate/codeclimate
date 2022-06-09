require "fileutils"
require "ipaddr"
require "json"
require "net/http"
require "pathname"
require "uri"

require "cc/resolv"

module CC
  module CLI
    class Prepare < Command
      ARGUMENT_LIST = "[--allow-internal-ips]".freeze
      SHORT_HELP = "Run the commands in your prepare step.".freeze
      HELP = "#{SHORT_HELP}\n" \
        "\n" \
        "    --allow-internal-ips    Allow fetching from internal IPs.".freeze

      InternalHostError = Class.new(StandardError)
      FetchError = Class.new(StandardError)

      PRIVATE_ADDRESS_SUBNETS = [
        IPAddr.new("10.0.0.0/8"),
        IPAddr.new("172.16.0.0/12"),
        IPAddr.new("192.168.0.0/16"),
        IPAddr.new("fd00::/8"),
        IPAddr.new("127.0.0.1"),
        IPAddr.new("0:0:0:0:0:0:0:1"),
        IPAddr.new("169.254.0.0/16"),
      ].freeze

      def run
        ::CC::Resolv.with_fixed_dns { fetch_all }
      rescue FetchError, InternalHostError => ex
        fatal(ex.message)
      end

      private

      def allow_internal_ips?
        @args.include?("--allow-internal-ips")
      end

      def fetches
        @fetches ||= config.prepare.fetch
      end

      def config
        @config ||= CC::Config.load
      end

      def fetch_all
        fetches.each do |entry|
          fetch(entry.url, entry.path)
        end
      end

      def fetch(url, target_path)
        ensure_external!(url) unless allow_internal_ips?

        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        resp = http.get(uri)
        if resp.code == "200"
          write_file(target_path, resp.body)
          say("Wrote #{url} to #{target_path}")
        else
          raise FetchError, "Failed fetching #{url}: code=#{resp.code}"
        end
      end

      def write_file(target_path, content)
        FileUtils.mkdir_p(Pathname.new(target_path).parent.to_s)
        File.write(target_path, content)
      end

      def ensure_external!(url)
        uri = URI.parse(url)

        if internal?(uri.host)
          raise InternalHostError, "Won't fetch #{url.inspect}: it maps to an internal address"
        end
      end

      # rubocop:disable Style/CaseEquality
      def internal?(host)
        address = ::Resolv.getaddress(host)

        PRIVATE_ADDRESS_SUBNETS.any? do |subnet|
          subnet === IPAddr.new(address.to_s)
        end
      rescue ::Resolv::ResolvError
        true # localhost
      end
      # rubocop:enable Style/CaseEquality
    end
  end
end
