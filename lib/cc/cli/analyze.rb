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

      include CC::Analyzer

      def initialize(_args = [])
        super

        @config = Config::Default.new
        @listener = ContainerListener.new
        @registry = EngineRegistry.new

        process_args
      end

      def run
        bridge = Bridge.new(
          config: config,
          formatter: formatter,
          listener: listener,
          registry: registry,
        )

        Dir.chdir(MountedPath.code.container_path) { bridge.run }
      end

      private

      attr_reader :config, :listener, :registry

      def process_args
        while (arg = @args.shift)
          case arg
          when "-f", "--format"
            @formatter = Formatters.resolve(@args.shift).new(filesystem)
          # when "-e", "--engine"
          #   @engine_options << @args.shift
          when "--dev"
            config.development = true
          else
            config.analysis_paths << arg
          end
        end
      rescue Formatters::Formatter::InvalidFormatterError => ex
        fatal(e.message)
      end

      def formatter
        @formatter ||= Formatters::PlainTextFormatter.new(filesystem)
      end
    end
  end
end
