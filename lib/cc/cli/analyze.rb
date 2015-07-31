module CC
  module CLI
    class Analyze < Command
      include CC::Analyzer

      def initialize(_args = [])
        super

        process_args
      end

      def run
        require_codeclimate_yml

        Dir.chdir(ENV['FILESYSTEM_DIR']) do
          runner = EnginesRunner.new(registry, formatter, source_dir, config)
          runner.run
        end

      rescue EnginesRunner::InvalidEngineName => ex
        fatal(ex.message)
      rescue EnginesRunner::NoEnabledEngines
        fatal("No enabled engines. Add some to your .codeclimate.yml file!")
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

      def registry
        EngineRegistry.new(@dev_mode)
      end

      def formatter
        @formatter ||= Formatters::PlainTextFormatter.new
      end

      def source_dir
        ENV["CODE_PATH"]
      end

      def config
        CC::Yaml.parse(filesystem.read_path(CODECLIMATE_YAML))
      end
    end
  end
end
