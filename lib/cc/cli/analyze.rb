require "cc/cli/command"

module CC
  module CLI
    class Analyze < Command
      ARGUMENT_LIST = "[-f format] [-e engine[:channel]] [path]".freeze
      SHORT_HELP = "Run analysis with the given arguments".freeze
      HELP = "#{SHORT_HELP}\n" \
        "\n" \
        "    -f <format>, --format <format>   Format of output. Possible values: #{CC::Analyzer::Formatters::FORMATTERS.keys.join ", "}\n" \
        "    -e <engine[:channel]>            Engine to run. Can be specified multiple times.\n" \
        "    --dev                            Run in development mode. Engines installed locally that are not in the manifest will be run.\n" \
        "    path                             Path to check. Can be specified multiple times.".freeze

      autoload :EngineFailure, "cc/cli/analyze/engine_failure"

      include CC::Analyzer

      def run
        # Load config here so it sees ./.codeclimate.yml
        @config = Config.load

        # process args after, so it modifies loaded configuration
        process_args

        bridge = Bridge.new(
          config: config,
          formatter: formatter,
          listener: CompositeContainerListener.new(
            LoggingContainerListener.new(Analyzer.logger),
            RaisingContainerListener.new(EngineFailure),
          ),
          registry: EngineRegistry.new,
        )

        bridge.run
      end

      private

      attr_reader :config, :engines_disabled, :listener, :registry

      def process_args
        while (arg = @args.shift)
          case arg
          when "-f", "--format"
            @formatter = Formatters.resolve(@args.shift).new(filesystem)
          when "-e", "--engine"
            disable_all_engines!
            name, channel = @args.shift.split(":", 2)
            enable_engine(name, channel)
          when "--dev"
            config.development = true
          when "--no-plugins"
            config.disable_plugins!
          else
            config.analysis_paths << arg
          end
        end
      rescue Formatters::Formatter::InvalidFormatterError => ex
        fatal(ex.message)
      end

      def formatter
        @formatter ||= Formatters::PlainTextFormatter.new(filesystem)
      end

      def disable_all_engines!
        unless engines_disabled
          config.engines.each { |e| e.enabled = false }
          @engines_disabled = true
        end
      end

      def enable_engine(name, channel)
        existing_engine = config.engines.detect { |e| e.name == name }
        if existing_engine.present?
          existing_engine.enabled = true
          existing_engine.channel = channel if channel.present?
        else
          config.engines << Config::Engine.new(
            name,
            channel: channel,
            enabled: true,
          )
        end
      end
    end
  end
end
