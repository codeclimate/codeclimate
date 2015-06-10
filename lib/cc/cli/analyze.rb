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

      def engine_config(engine_name)
        file = Tempfile.new('config.json')
        json = config.engine_config(engine_name).
          merge!(exclude_paths: exclude_paths).to_json
        file.write(json)
        file.path
      end

      def exclude_paths
        if config.exclude_paths
          filesystem.files_matching(config.exclude_paths)
        else
          []
        end
      end

      def engines
        @engines ||= config.engine_names.map do |engine_name|
          Engine.new(
            engine_name,
            engine_registry[engine_name],
            path,
            engine_config(engine_name),
            SecureRandom.uuid
          )
        end
      end

      def filesystem
        @filesystem ||= Filesystem.new(ENV['FILESYSTEM_DIR'])
      end

      def formatter
        @formatter ||= Formatters::PlainTextFormatter.new
      end

      def path
        ENV['CODE_PATH']
      end

    end
  end
end
