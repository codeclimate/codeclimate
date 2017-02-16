module CC
  module CLI
    class Config
      delegate :to_yaml, to: :config

      def initialize(config = {})
        @config = default_config.merge(config)
      end

      def add_engine(engine_name, engine_config)
        config["engines"][engine_name] = { "enabled" => true }

        if engine_config["default_config"].present?
          config["engines"][engine_name]["config"] = engine_config["default_config"]
        end

        # we may not want this code in the general case.
        # for now, we need it to test one of our own Maintainability engines
        # which is in the 'beta' channel
        if engine_config.key?("channels") && !engine_config["channels"].include?("stable")
          config["engines"][engine_name]["channel"] = engine_config["channels"].first.first
        end

        config["ratings"]["paths"] |= engine_config["default_ratings_paths"]
      end

      def add_exclude_paths(paths)
        config["exclude_paths"] ||= []
        config["exclude_paths"] |= paths
      end

      private

      attr_reader :config

      def default_config
        {
          "engines" => {},
          "ratings" => { "paths" => [] },
        }
      end
    end
  end
end
