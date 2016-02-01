module CC
  module CLI
    class Config
      delegate :to_yaml, to: :config
      def initialize
        @config = {
          "engines" => {},
          "ratings" => { "paths" => [] },
        }
      end

      def add_engine(engine_name, engine_config)
        config["engines"][engine_name] = { "enabled" => true }

        if engine_config["default_config"].present?
          config["engines"][engine_name]["config"] = engine_config["default_config"]
        end

        config["ratings"]["paths"] |= engine_config["default_ratings_paths"]
      end

      def add_exclude_paths(paths)
        config["exclude_paths"] ||= []
        config["exclude_paths"] |= paths
      end

      private

      attr_reader :config
    end
  end
end
