module CC
  module CLI
    class Init < Command
      include CC::Analyzer

      AUTO_EXCLUDE_PATHS = %w[config db features node_modules script spec test vendor].freeze

      def run
        if filesystem.exist?(CODECLIMATE_YAML)
          say "Config file .codeclimate.yml already present.\nTry running 'validate-config' to check configuration."
        else
          create_codeclimate_yaml
          say "Config file .codeclimate.yml successfully generated.\nEdit and then try running 'validate-config' to check configuration."
        end
      end

      private

      def create_codeclimate_yaml
        config = { "engines" => {} }
        eligible_engines.each do |engine_name, engine_config|
          config["engines"][engine_name] = {
            "enabled" => true
          }
          config["ratings"] ||= {}
          config["ratings"]["paths"] ||= []

          config["ratings"]["paths"] |= engine_config["default_ratings_paths"]
        end

        config["exclude_paths"] = exclude_paths(AUTO_EXCLUDE_PATHS)

        filesystem.write_path(CODECLIMATE_YAML, config.to_yaml)
      end

      def exclude_paths(paths)
        expanded_paths = []
        paths.each do |dir|
          if filesystem.exist?(dir)
            expanded_paths << "#{dir}/**/*"
          end
        end
        expanded_paths
      end

      def engine_eligible?(engine)
        !engine["community"] &&
          engine["enable_regexps"].present? &&
          filesystem.any? do |path|
            engine["enable_regexps"].any? { |re| Regexp.new(re).match(path) }
          end
      end

      def eligible_engines
        CC::Analyzer::EngineRegistry.new.list.each_with_object({}) do |(engine_name, config), result|
          if engine_eligible?(config)
            result[engine_name] = config
          end
        end
      end
    end
  end
end
