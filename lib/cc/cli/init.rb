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
          create_default_configs
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

      def create_default_configs
        available_configs.each do |config_path|
          file_name = File.basename(config_path)
          if filesystem.exist?(file_name)
            say "Skipping generating #{file_name} file (already exists)."
          else
            filesystem.write_path(file_name, File.read(config_path))
            say "Config file #{file_name} successfully generated."
          end
        end
      end

      def available_configs
        all_paths = eligible_engines.flat_map do |engine_name, _|
          engine_directory = File.expand_path("../../../../config/#{engine_name}", __FILE__)
          Dir.glob("#{engine_directory}/*", File::FNM_DOTMATCH)
        end

        all_paths.reject { |path| ['.', '..'].include?(File.basename(path)) }
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
        @eligible_engines ||= engine_registry.list.each_with_object({}) do |(engine_name, config), result|
          if engine_eligible?(config)
            result[engine_name] = config
          end
        end
      end
    end
  end
end
