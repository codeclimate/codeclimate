require "posix/spawn"
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

      def run(stdout_io, container_log = NullContainerLog.new)
        container = Container.new(
          @metadata["image"],
          @metadata["command"],
          ContainerLogLog.new(name, container_log)
        )

        container.on_output("\0") do |chunk|
          output = chunk.chomp("\0")

          unless output_filter.filter?(output)
            stdout_io.write(output)
          end
        end

        container.run(container_options)
      end

      private

      def container_options
        [
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=#{@label}",
          "--name", container_name,
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

      class ContainerLog
        def initialize(name, inner_log)
          @name = name
          @inner_log = inner_log
        end

        def started(image)
          @inner_log.started(image)

          Analyzer.statsd.increment("cli.engines.started")
        end

        def timed_out
          @inner_log.timed_out

          Analyzer.statsd.increment("cli.engines.result.error")
          Analyzer.statsd.increment("cli.engines.result.error.timeout")
          Analyzer.statsd.increment("cli.engines.names.#{@name}.result.error")
          Analyzer.statsd.increment("cli.engines.names.#{@name}.result.error.timeout")

          raise EngineTimeout, "engine #{@name} ran past #{TIMEOUT} seconds and was killed"
        end

        def finished(status, stderr)
          @inner_log.finished(status, stderr)

          Analyzer.statsd.increment("cli.engines.finished")

          if status.success?
            Analyzer.statsd.increment("cli.engines.result.success")
            Analyzer.statsd.increment("cli.engines.names.#{@name}.result.success")
          else
            Analyzer.statsd.increment("cli.engines.result.error")
            Analyzer.statsd.increment("cli.engines.names.#{@name}.result.error")
            raise EngineFailure, "engine #{@name} failed with status #{status.exitstatus} and stderr \n#{stderr}"
          end
        end
      end
    end
  end
end
