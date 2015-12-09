require "securerandom"
require "cc/analyzer/engine/errors"

module CC
  module Analyzer
    class Engine
      attr_reader :name

      DEFAULT_MEMORY_LIMIT = 512_000_000.freeze

      def initialize(name, metadata, code_path, config, label)
        @name = name
        @metadata = metadata
        @code_path = code_path
        @config = config
        @label = label.to_s
      end

      def run(stdout_io, container_listener)
        composite_listener = CompositeContainerListener.new(
          container_listener,
          LoggingContainerListener.new(name, Analyzer.logger),
          StatsdContainerListener.new(name, Analyzer.statsd),
          RaisingContainerListener.new(name, EngineFailure, EngineTimeout),
        )

        container = Container.new(
          image: @metadata["image"],
          command: @metadata["command"],
          name: container_name,
          listener: composite_listener,
        )

        container.on_output("\0") do |output|
          unless output_filter.filter?(output)
            stdout_io.write(output) || container.stop
          end
        end

        container.run(container_options)
      end

      private

      def container_options
        [
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=#{@label}",
          "--memory", memory_limit,
          "--memory-swap", "-1",
          "--net", "none",
          "--volume", "#{@code_path}:/code:ro",
          "--volume", "#{config_file}:/config.json:ro",
          "--user", "9000:9000"
        ]
      end

      def container_name
        @container_name ||= "cc-engines-#{name}-#{SecureRandom.uuid}"
      end

      def config_file
        path = File.join("/tmp/cc", SecureRandom.uuid)
        FileUtils.mkdir_p("/tmp/cc")
        File.write(path, @config.to_json)
        path
      end

      def output_filter
        @output_filter ||= EngineOutputFilter.new(@config)
      end

      # Memory limit for a running engine in bytes
      def memory_limit
        (ENV["ENGINE_MEMORY_LIMIT_BYTES"] || DEFAULT_MEMORY_LIMIT).to_s
      end
    end
  end
end
