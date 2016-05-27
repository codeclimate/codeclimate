require "securerandom"

module CC
  module Analyzer
    class Engine
      EngineFailure = Class.new(StandardError)
      EngineTimeout = Class.new(StandardError)

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
          LoggingContainerListener.new(qualified_name, Analyzer.logger),
          StatsdContainerListener.new(qualified_name.tr(":", "."), Analyzer.statsd),
          RaisingContainerListener.new(qualified_name, EngineFailure, EngineTimeout),
        )

        container = Container.new(
          image: @metadata["image"],
          command: @metadata["command"],
          name: container_name,
          listener: composite_listener,
        )

        container.on_output("\0") do |raw_output|
          CLI.debug("#{qualified_name} engine output: #{raw_output.strip}")
          output = EngineOutput.new(raw_output)

          unless output.valid?
            stdout_io.failed("#{qualified_name} produced invalid output: #{output.error[:message]}")
            container.stop
          end

          unless output_filter.filter?(output)
            stdout_io.write(output.to_json) || container.stop
          end
        end

        write_config_file
        CLI.debug("#{qualified_name} engine config: #{config_file.read}")
        container.run(container_options).tap do |result|
          CLI.debug("#{qualified_name} engine stderr: #{result.stderr}")
        end
      rescue Container::ImageRequired
        # Provide a clearer message given the context we have
        message = "Unable to find an image for #{qualified_name}."
        message << " Available channels: #{@metadata["channels"].keys.inspect}."
        raise Container::ImageRequired, message
      ensure
        delete_config_file
      end

      private

      def qualified_name
        "#{name}:#{@config.fetch("channel", "stable")}"
      end

      def container_options
        [
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=#{@label}",
          "--memory", memory_limit,
          "--memory-swap", "-1",
          "--net", "none",
          "--rm",
          "--volume", "#{@code_path}:/code:ro",
          "--volume", "#{config_file.host_path}:/config.json:ro",
          "--user", "9000:9000"
        ]
      end

      def container_name
        @container_name ||= "cc-engines-#{qualified_name.tr(":", "-")}-#{SecureRandom.uuid}"
      end

      def write_config_file
        config_file.write(@config.to_json)
      end

      def delete_config_file
        config_file.delete if config_file.file?
      end

      def config_file
        @config_file ||= MountedPath.tmp.join(SecureRandom.uuid)
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
