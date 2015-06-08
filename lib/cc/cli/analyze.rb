require "cc/analyzer"

module CC
  module CLI
    class Analyze < Command
      include CC::Analyzer

      CODECLIMATE_YAML = ".codeclimate.yml".freeze

      def run
        engines.each do |engine|
          engine.run(STDOUT)
        end
      end

      private

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
        @formatter ||= Formatters::JSON.new
      end

      def path
        @args.first || Dir.pwd
      end

    end
  end
end
