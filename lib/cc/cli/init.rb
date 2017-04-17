require "cc/cli/config"
require "cc/cli/config_generator"
require "cc/cli/upgrade_config_generator"

module CC
  module CLI
    class Init < Command
      include CC::Analyzer

      ARGUMENT_LIST = "[--upgrade]".freeze
      SHORT_HELP = "Generate a configuration based on the contents of your repo.".freeze
      HELP = "#{SHORT_HELP}\n" \
        "\n" \
        "    --upgrade    Upgrade a Code Climate Classic configuration".freeze

      def run
        if !upgrade? && filesystem.exist?(CODECLIMATE_YAML)
          warn "Config file .codeclimate.yml already present.\nTry running 'validate-config' to check configuration."
          create_default_engine_configs if engines_enabled?
        elsif upgrade? && engines_enabled?
          warn "Config file .codeclimate.yml already configured for the Platform.\nTry running 'validate-config' to check configuration."
          create_default_engine_configs
        else
          generate_all_config
        end
      end

      private

      def upgrade?
        @args.include?("--upgrade")
      end

      def generate_all_config
        unless config_generator.can_generate?
          config_generator.errors.each do |error|
            $stderr.puts colorize("ERROR: #{error}", :red)
          end
          fatal "Cannot generate .codeclimate.yml: please address above errors."
        end

        create_codeclimate_yaml
        success "Config file .codeclimate.yml successfully #{config_generator.post_generation_verb}.\nEdit and then try running 'validate-config' to check configuration."
        create_default_engine_configs
      end

      def create_codeclimate_yaml
        say "Generating .codeclimate.yml..."
        config = CC::CLI::Config.new

        config_generator.eligible_engines.each do |(engine_name, engine_config)|
          config.add_engine(engine_name, engine_config)
        end

        config.add_exclude_paths(config_generator.exclude_paths)
        filesystem.write_path(CODECLIMATE_YAML, config.to_yaml)
      end

      def create_default_engine_configs
        say "Generating default configuration for engines..."
        available_engine_configs.each do |(engine_name, config_paths)|
          if (engine = engine_registry[engine_name])
            config_mapping = Hash.new { |_, k| [k] }.merge(engine.fetch("config_files", {}))

            config_paths.each do |config_path|
              filename = File.basename(config_path)
              possible_names = config_mapping[filename].concat([filename])
              generate_config(config_path, possible_names)
            end
          end
        end
      end

      def generate_config(config_path, possible_names)
        file_name = File.basename(config_path)
        existing_files = possible_names.select do |f|
          filesystem.exist? f
        end
        if existing_files.any?
          say "Skipping generating #{file_name}, existing file(s) found: #{existing_files.join(", ")}"
        else
          filesystem.write_path(file_name, File.read(config_path))
          success "Config file #{file_name} successfully generated."
        end
      end

      def available_engine_configs
        engines = existing_cc_config.engines || {}
        engine_names = engines.select { |_, config| config.enabled? }.keys

        engine_names.map do |engine_name|
          engine_directory = File.expand_path("../../../config/#{engine_name}", __dir__)
          [
            engine_name,
            Dir.glob("#{engine_directory}/*", File::FNM_DOTMATCH).
              reject { |path| %w[. ..].include?(File.basename(path)) },
          ]
        end
      end

      def engines_enabled?
        cc_config = existing_cc_config
        cc_config.present? && cc_config.engines.present?
      end

      def config_generator
        @config_generator ||= ConfigGenerator.for(filesystem, engine_registry, upgrade?)
      end

      def existing_cc_config
        if filesystem.exist?(CODECLIMATE_YAML)
          CC::Yaml.parse(filesystem.read_path(CODECLIMATE_YAML))
        end
      end
    end
  end
end
