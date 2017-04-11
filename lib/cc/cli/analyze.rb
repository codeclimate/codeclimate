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
        @engine_options = []
        @path_options = []

        process_args
        apply_config_options
      end

      def run
        require_codeclimate_yml

        Dir.chdir(MountedPath.code.container_path) do
          runner = EnginesRunner.new(registry, formatter, source_dir, config, path_options)
          runner.run
        end
      rescue EnginesRunner::NoEnabledEngines
        fatal("No enabled engines. Add some to your .codeclimate.yml file!")
      end

      private

      attr_accessor :config
      attr_reader :engine_options, :path_options

      def process_args
        while (arg = @args.shift)
          case arg
          when "-f"
            @formatter = Formatters.resolve(@args.shift).new(filesystem)
          when "-e", "--engine"
            @engine_options << @args.shift
          when "--dev"
            @dev_mode = true
          else
            @path_options << arg
          end
        end
      rescue Formatters::Formatter::InvalidFormatterError => e
        fatal(e.message)
      end

      def registry
        EngineRegistry.new(@dev_mode)
      end

      def formatter
        @formatter ||= Formatters::PlainTextFormatter.new(filesystem)
      end

      def source_dir
        MountedPath.code.host_path
      end

      def config
        @config ||= CC::Yaml.parse(filesystem.read_path(CODECLIMATE_YAML))
      end

      def apply_config_options
        if engine_options.any? && config.engines?
          filter_by_engine_options
        elsif engine_options.any?
          config["engines"] = CC::Yaml::Nodes::EngineList.new(config).with_value({})
        end
        add_engine_options
      end

      def filter_by_engine_options
        config.engines.keys.each do |engine|
          unless engine_options.include?(engine)
            config.engines.delete(engine)
          end
        end
      end

      def add_engine_options
        engine_options.each do |engine|
          name, channel = engine.split(":", 2)

          if config.engines.include?(engine)
            config.engines[name].enabled = true
            config.engines[name].channel = channel if channel
          else
            value = { "enabled" => true }
            value["channel"] = channel if channel
            config.engines[name] = CC::Yaml::Nodes::Engine.new(config.engines).with_value(value)
          end
        end
      end
    end
  end
end
