module CC
  module Analyzer
    class EngineAnalysis
      attr_reader :formatter

      def initialize(config, engine_name, formatter)
        @config = config
        @engine_name = engine_name
        @formatter = formatter
        validate_name
      end

      def run
        engine_process.run do
          client.wait_for_port
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
            source_buffer = SourceBuffer.from_path(path)
            result = AnalysisResult.new(source_buffer, { "issues" => issues })
            formatter.file_analyzed(path, result)
          end
        end
      end

    private

      def analyze_file(path)
        source_buffer = SourceBuffer.from_path(path)

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
            tree:   Dir["**/*.*"].sort.select { |path| File.file?(path) }
          )

          response.body["paths"]
        end
      end

      def client
        @client ||= EngineClient.new(engine_process.wait_for_url)
      end

      def engine_process
        @engine_process ||= EngineProcess.new(@engine_name)
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
