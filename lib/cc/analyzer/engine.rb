require "securerandom"

module CC
  module Analyzer
    class Engine
      EngineFailure = Class.new(StandardError)
      EngineTimeout = Class.new(StandardError)

      attr_reader :name

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
          "--memory", 512_000_000.to_s, # bytes
          "--memory-swap", "-1",
          "--net", "none",
          "--volume", "#{@code_path}:/code:ro",
          "--volume", "#{config_file}:/config.json:ro",
          "--user", "9000:9000",
        ]
      end

      def container_name
        @container_name ||= "cc-engines-#{name}-#{SecureRandom.uuid}"
      end

      def config_file
        path = File.join("/tmp/cc", SecureRandom.uuid)
        File.write(path, @config.to_json)
        path
      end

      def output_filter
        @output_filter ||= EngineOutputFilter.new(@config)
      end
    end
  end
end
