require "securerandom"

module CC
  module Analyzer
    #
    # Running specifically an Engine container
    #
    # Input:
    #   - name
    #   - metadata
    #     - image
    #     - command (optional)
    #   - config (becomes /config.json)
    #   - label
    #   - io (to write filtered, validated output)
    #
    # Output:
    #   - Container::Result
    #
    class Engine
      Error = Class.new(StandardError)

      DEFAULT_MEMORY_LIMIT = 512_000_000

      def initialize(name, metadata, config, label)
        @name = name
        @metadata = metadata
        @config = config
        @label = label.to_s
      end

      def run(io)
        write_config_file

        container = Container.new(
          image: @metadata.fetch("image"),
          command: @metadata["command"],
          name: container_name,
        )

        container.on_output("\0") do |output|
          handle_output(container, io, output)
        end

        container.run(container_options)
      rescue Error => ex
        Container::Result.from_exception(ex)
      ensure
        delete_config_file
      end

      private

      attr_reader :name

      def handle_output(container, io, raw_output)
        output = EngineOutput.new(name, raw_output)

        return if output_filter.filter?(output)

        unless output.valid?
          container.stop("output invalid")
          raise Error, "engine produced invalid output: #{output.error}"
        end

        unless io.write(output_overrider.apply(output).to_json)
          container.stop("output error")
          raise Error, "#{io.class}#write returned false, indicating an error"
        end
      end

      def qualified_name
        "#{name}:#{@config.fetch("channel", "stable")}"
      end

      def container_options
        [
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=#{@label}",
          "--log-driver", "none",
          "--memory", memory_limit,
          "--memory-swap", "-1",
          "--net", "none",
          "--rm",
          "--volume", "#{code.host_path}:/code:ro",
          "--volume", "#{config_file.host_path}:/config.json:ro",
          "--user", "9000:9000"
        ]
      end

      def container_name
        @container_name ||= "cc-engines-#{qualified_name.tr(":", "-")}-#{SecureRandom.uuid}"
      end

      def write_config_file
        Analyzer.logger.debug "/config.json content: #{@config.inspect}"
        config_file.write(@config.to_json)
      end

      def delete_config_file
        config_file.delete if config_file.file?
      end

      def code
        @code ||= MountedPath.code
      end

      def config_file
        @config_file ||= MountedPath.tmp.join(SecureRandom.uuid)
      end

      def output_filter
        @output_filter ||= EngineOutputFilter.new(@config)
      end

      def output_overrider
        @output_overrider ||= EngineOutputOverrider.new(@config)
      end

      # Memory limit for a running engine in bytes
      def memory_limit
        (ENV["ENGINE_MEMORY_LIMIT_BYTES"] || DEFAULT_MEMORY_LIMIT).to_s
      end
    end
  end
end
