module CC
  class Config
    class EngineSet
      attr_reader :engines

      def initialize(data)
        @data = data
        @engines = []

        build_set
      end

      private

      attr_reader :data

      def build_set
        DefaultAdapter::ENGINES.keys.each do |name|
          if (engine = extract_engine(name))
            engines << engine
          end
        end

        data.each do |name, engine_data|
          engines << build_engine(name, engine_data)
        end
      end

      def extract_engine(name)
        if data[name]
          engine_data = data.delete(name)
          build_engine(name, engine_data)
        end
      end

      def build_engine(name, data)
        Config::Engine.new(
          name,
          enabled: data.fetch("enabled", true),
          channel: data["channel"],
          config: data,
          exclude_patterns: data.fetch("exclude_patterns", []),
        )
      end
    end
  end
end
