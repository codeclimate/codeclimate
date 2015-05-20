require "cc/analyzer"

module CC
  module CLI
    class Analyze < Command
      include CC::Analyzer

      def run
        config = Config.from_file(".codeclimate.yml")
        formatter = Formatter.new

        config.engine_names.each do |engine_name|
          analysis = EngineAnalysis.new(config, engine_name, formatter)
          analysis.run
        end

        formatter.finished
      end

    end
  end
end
