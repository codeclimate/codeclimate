require "socket"
require "timeout"
require "faraday"
require "faraday_middleware"

module CC
  module Analyzer
    class EngineClient

      def initialize(url)
        @url = url
      end

      def wait_for_port
        Timeout.timeout(10) do
          sleep 0.05 while !port_open?
        end
      end

      def get(path)
        response = conn.get(path)
        validate_response(response)
        response
      end

      def post(path, body_json)
        response = conn.post(path, body_json)
        validate_response(response)
        response
      end

    private

      def validate_response(response)
        if response.status != 200
          raise "Unexpected response: #{response.status}\n\n#{response.body}"
        end
      end

      def conn
        @conn ||= Faraday.new(url: @url) do |conn|
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          # conn.response :logger, nil, bodies: true
          conn.adapter Faraday.default_adapter
        end
      end

      def port_open?
        port = URI.parse(@url).port

        begin
          Timeout.timeout(1) do
            begin
              TCPSocket.new('127.0.0.1', port).close
              return true
            rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
              return false
            end
          end
        rescue Timeout::Error
        end

        return false
      end

    end
  end
end
