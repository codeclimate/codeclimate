require "cc/yaml"

module CC
  module CLI
    class ValidateConfig < Command
      SHORT_HELP = "Validate your .codeclimate.yml.".freeze
      VALID_CONFIG_MESSAGE = "No errors or warnings found in .codeclimate.yml file.".freeze

      def run
        require_codeclimate_yml
        process_args

        if any_issues?
          display_issues
        else
          puts VALID_CONFIG_MESSAGE
        end

        exit 1 unless validator.valid?
      end

      private

      attr_reader :config, :registry, :validator

      def process_args
        registry_path = EngineRegistry::DEFAULT_MANIFEST_PATH
        registry_prefix = ""

        # Undocumented; we only need these from Builder so we can validate
        # engines/channels against our own registry and prefix.
        while (arg = @args.shift)
          case arg
          when "--registry" then registry_path = @args.shift
          when "--registry-prefix" then registry_prefix = @args.shift
          end
        end

        @validator = Config::YAML::Validator.new(
          Config::YAMLAdapter::DEFAULT_PATH,
          EngineRegistry.new(registry_path, registry_prefix),
        )
      end

      def any_issues?
        validator.errors.any? ||
          validator.warnings.any? ||
          validator.nested_warnings.any?
      end

      def display_issues
        validator.errors.each do |error|
          puts "#{colorize("ERROR", :red)}: #{error}"
        end

        validator.warnings.each do |warning|
          puts "#{colorize("WARNING", :yellow)}: #{warning}"
        end

        validator.nested_warnings.each do |warning|
          puts "#{colorize("WARNING in #{warning.field}", :yellow)}: #{warning.message}"
        end
      end
    end
  end
end
