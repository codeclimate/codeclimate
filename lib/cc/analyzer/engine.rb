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

      def initialize(name, metadata, config, label)
        @name = name
        @metadata = metadata
        @config = config
        @label = label.to_s
        @error = nil
      end

      def run(io)
        write_config_file

        container = Container.new(
          image: metadata.fetch("image"),
          command: metadata["command"],
          name: container_name,
        )

        container.on_output("\0") do |output|
          handle_output(container, io, output)
        end

        container.run(container_options).tap do |result|
          result.merge_from_exception(error) if error.present?
        end
      ensure
        delete_config_file
      end

      private

      attr_reader :name, :metadata
      attr_accessor :error

      def handle_output(container, io, raw_output)
        output = EngineOutput.new(name, raw_output)

        return if output_filter.filter?(output)

        unless output.valid?
          self.error = Error.new("engine produced invalid output: #{output.error}")
          container.stop("output invalid")
        end

        unless io.write(output_overrider.apply(output).to_json)
          self.error = Error.new("#{io.class}#write returned false, indicating an error")
          container.stop("output error")
        end
      end

      def qualified_name
        "#{name}:#{@config.fetch("channel", "stable")}"
      end

      def container_options
        options = [
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=#{@label}",
          "--log-driver", "none",
          "--memory-swap", "-1",
          "--net", "none",
          "--rm",
          "--volume", "#{code.host_path}:/code:ro",
          "--volume", "#{config_file.host_path}:/config.json:ro",
          "--user", "9000:9000"
        ]
        if (memory = metadata["memory"]).present?
          options.concat(["--memory", memory.to_s])
        end
        options
      end

      def container_name
        @container_name ||= "cc-engines-#{qualified_name.tr(":", "-")}-#{SecureRandom.uuid}"
      end

      def write_config_file
        @config["debug"] = ENV["CODECLIMATE_DEBUG"]
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
    end
  end
end
