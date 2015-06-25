require "securerandom"

module CC
  module CLI
    class Analyze < Command
      include CC::Analyzer

      def initialize(args = [])
        super

        process_args
      end

      def run
        require_codeclimate_yml
        if engines.empty?
          fatal("No engines enabled. Add some to your .codeclimate.yml file!")
        end

        formatter.started

        engines.each do |engine|
          formatter.engine_running(engine) do
            engine.run(formatter)
          end
        end

        formatter.finished
      end

      private

      def process_args
        case @args.first
        when '-f'
          @args.shift # throw out the -f
          @formatter = Formatters.resolve(@args.shift)
        when '-dev'
          @dev_mode = true
        end
      rescue Formatters::Formatter::InvalidFormatterError => e
        fatal(e.message)
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
        config.engine_config(engine_name).
          merge!(exclude_paths: exclude_paths).to_json
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
            @dev_mode ? make_registry_entry(engine_name) : engine_registry[engine_name],
            path,
            engine_config(engine_name),
            SecureRandom.uuid
          )
        end
      end

      def formatter
        @formatter ||= Formatters::PlainTextFormatter.new
      end

      def path
        ENV['CODE_PATH']
      end

      def make_registry_entry(engine_name)
        {
          "image_name"=>"codeclimate/codeclimate-#{engine_name}:latest"
        }
      end

    end
  end
end
