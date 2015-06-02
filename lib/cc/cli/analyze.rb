require "cc/analyzer"

module CC
  module CLI
    class Analyze < Command
      include CC::Analyzer

      CODECLIMATE_YAML = ".codeclimate.yml".freeze

      def run
        if filesystem.exist?(CODECLIMATE_YAML)
          config_body = filesystem.read_path(CODECLIMATE_YAML)
          config = Config.new(config_body)
        else
          config = NullConfig.new
        end

        config.engine_names.each do |engine_name|
          analysis = EngineAnalysis.new(config, engine_name, formatter, filesystem)
          analysis.run
        end

        formatter.finished
      end

      def filesystem
        @filesystem ||= Filesystem.new(".")
      end

      def formatter
        @formatter ||= Formatters::JSON.new
      end

    end
  end
end
