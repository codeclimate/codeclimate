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

      def dev_mode?
        !!@dev_mode
      end

      private

      def process_args
        while arg = @args.shift
          case arg
          when '-f'
            @formatter = Formatters.resolve(@args.shift)
          when '--dev'
            @dev_mode = true
          end
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
          entry = registry_entry(engine_name)
          if entry.nil?
            fatal("unknown engine name: #{engine_name}")
          else
            Engine.new(
              engine_name,
              entry,
              path,
              engine_config(engine_name),
              SecureRandom.uuid
            )
          end
        end.compact
      end

      def formatter
        @formatter ||= Formatters::PlainTextFormatter.new(filesystem)
      end

      def path
        ENV['CODE_PATH']
      end

      def registry_entry(engine_name)
        if @dev_mode
          dev_registry_entry(engine_name)
        else
          engine_registry[engine_name]
        end
      end

      def dev_registry_entry(engine_name)
        {
          "image"=>"codeclimate/codeclimate-#{engine_name}:latest"
        }
      end

    end
  end
end
