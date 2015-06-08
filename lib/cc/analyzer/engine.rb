require 'docker'

module CC
  module Analyzer
    class Engine
      attr_reader :name

      TIMEOUT = 15 * 60 # 15m

      def initialize(name, metadata, code_path, label = SecureRandom.uuid)
        @name = name
        @metadata = metadata
        @code_path = code_path
        @label = label.to_s
      end

      def run(stdout_io)
        accumulator = Accumulator.new("\0")
        accumulator.on_flush { |chunk| stdout_io.write(chunk) }

        container.start

        container.attach do |stream, output|
          if stream == :stdout
            accumulator << output
          end
        end

        container.wait(TIMEOUT)
      end

      def destroy
        container.stop
        container.remove(force: true)
      end

      private

      def container
        Excon.defaults[:ssl_verify_peer] = false # TODO: use certs
        @container ||= Docker::Container.create(
          "Image" => @metadata["image_name"],
          "Cmd" => @metadata["command"],
          "MemorySwap" => -1,
          "Memory" => 512_000_000, # bytes
          "Labels" => {
            "com.codeclimate.label" => @label
          },
          "NetworkDisabled" => true,
          "CapDrop" => ["ALL"],
          "Binds" => [
            "#{@code_path}:/code:ro",
          ]
        )
      end
    end
  end
end
