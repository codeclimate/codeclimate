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

        container.on_output("\0") do |raw_output|
          CLI.debug "engine output: #{raw_output.inspect}"
          output = EngineOutput.new(raw_output)

          unless output_filter.filter?(output)
            stdout_io.write(output.to_json) || container.stop
          end
        end

        write_config_file
        CLI.debug "engine config: #{File.read(config_file).inspect}"
        container.run(container_options)
      ensure
        delete_config_file
      end

      private

      def container_options
        [
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=#{@label}",
          "--memory", memory_limit,
          "--memory-swap", "-1",
          "--net", "none",
          "--rm",
          "--volume", "#{@code_path}:/code:ro",
          "--volume", "#{config_file}:/config.json:ro",
          "--user", "9000:9000"
        ]
      end

      def container_name
        @container_name ||= "cc-engines-#{name}-#{SecureRandom.uuid}"
      end

      def write_config_file
        FileUtils.mkdir_p(File.dirname(config_file))
        File.write(config_file, @config.to_json)
      end

      def delete_config_file
        File.delete(config_file) if File.file?(config_file)
      end

      def config_file
        @config_file ||= File.join("/tmp/cc", SecureRandom.uuid)
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
