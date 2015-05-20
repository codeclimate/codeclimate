require "cc/analyzer"

module CC
  module CLI
    class Analyze < Command
      include CC::Analyzer

      def run
        config_body = filesystem.read_path(".codeclimate.yml")
        config = Config.new(config_body)

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
