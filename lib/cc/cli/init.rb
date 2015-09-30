require 'cc/cli/config'

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
        config = CC::CLI::Config.new

        eligible_engines.each do |(engine_name, engine_config)|
          config.add_engine(engine_name, engine_config)
        end

        config.add_exclude_paths(auto_exclude_paths)
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

      def engine_eligible?(engine)
        !engine["community"] && engine["enable_regexps"].present? && has_files?(engine)
      end

      def has_files?(engine)
        filesystem.any? do |path|
          engine["enable_regexps"].any? { |re| Regexp.new(re).match(path) }
        end
      end

      def auto_exclude_paths
        AUTO_EXCLUDE_PATHS.select { |path| filesystem.exist?(path) }
      end

      def eligible_engines
        return @eligible_engines if @eligible_engines

        engines = engine_registry.list
        @eligible_engines = engines.each_with_object({}) do |(name, config), result|
          if engine_eligible?(config)
            result[name] = config
          end
        end
      end
    end
  end
end
