module CC
  module CLI
    class Analyze < Command
      include CC::Analyzer

      CODECLIMATE_YAML = ".codeclimate.yml".freeze

      def initialize(args = [])
        super

        process_args
      end

      def run
        formatter.started
        engines.each do |engine|
          engine.run(formatter)
        end
        formatter.finished
      end

      private

      def process_args
        case @args.first
        when '-f'
          @args.shift # throw out the -f
          @formatter = Formatters.resolve(@args.shift)
        end
      rescue Formatters::Formatter::InvalidFormatterError => e
        $stderr.puts e.message
        exit 1
      end

      def config
        @config ||= if filesystem.exist?(CODECLIMATE_YAML)
          config_body = filesystem.read_path(CODECLIMATE_YAML)
          config = Config.new(config_body)
        else
          config = NullConfig.new
        end
      end

      def engine_registry
        @engine_registry ||= EngineRegistry.new
      end

      def engines
        @engines ||= config.engine_names.map do |engine_name|
          Engine.new(
            engine_name,
            engine_registry[engine_name],
            path
          )
        end
      end

      def filesystem
        @filesystem ||= Filesystem.new(path)
      end

      def formatter
        @formatter ||= Formatters::PlainTextFormatter.new
      end

      def path
        @args.last || Dir.pwd
      end

    end
  end
end
