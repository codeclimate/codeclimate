module CC
  module Analyzer
    class EngineAnalysis
      attr_reader :formatter

      def initialize(config, engine_name, formatter, filesystem)
        @config = config
        @engine_name = engine_name
        @formatter = formatter
        @filesystem = filesystem
        validate_name
      end

      def run
        formatter.started(@engine_name, paths)

        paths.each do |path|
          analyze_file(path)
        end

        response = client.get("/finish")
        issues = Array.wrap(response.body["issues"])
        issues_by_path = issues.group_by do |doc|
          doc["location"]["path"]
        end

        issues_by_path.each do |path, issues|
          source_buffer = @filesystem.source_buffer_for(path)
          result = AnalysisResult.new(source_buffer, { "issues" => issues })
          formatter.file_analyzed(path, result)
        end
      end

    private

      def analyze_file(path)
        source_buffer = @filesystem.source_buffer_for(path)

        response = client.post("/analyze",
          path:         source_buffer.name,
          source_code:  source_buffer.source
        )

        result = AnalysisResult.new(source_buffer, response.body)
        formatter.file_analyzed(path, result)
      end

      def paths
        @paths ||= begin
          response = client.post("/configure",
            config: @config.to_hash,
            tree:   @filesystem.file_paths
          )

          response.body["paths"]
        end
      end

      def client
        @client ||= EngineClient.new(ENV["CODECLIMATE_ENGINE_#{@engine_name.upcase}_URL"])
      end

      def validate_name
        if @engine_name.blank?
          $stderr.puts "unknown analyzer"
          exit 1
        end
      end

    end
  end
end
