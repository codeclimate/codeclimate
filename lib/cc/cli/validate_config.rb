require "cc/yaml"

module CC
  module CLI
    class ValidateConfig < Command
      SHORT_HELP = "Validate your .codeclimate.yml or .codeclimate.json.".freeze
      VALID_CONFIG_MESSAGE = "No errors or warnings found in %s.".freeze

      def run
        require_codeclimate_yml
        process_args

        if any_issues?
          display_issues
        else
          puts sprintf(VALID_CONFIG_MESSAGE, ".codeclimate.yml")
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

        @validator = Config::Validation::YAML.new(
          Config::YAMLAdapter::DEFAULT_PATH,
          EngineRegistry.new(registry_path, registry_prefix),
        )
      end

      def any_issues?
        validator.errors.any? ||
          validator.warnings.any?
      end

      def display_issues
        validator.errors.each do |error|
          puts "#{colorize("ERROR", :red)}: #{error}"
        end

        validator.warnings.each do |warning|
          puts "#{colorize("WARNING", :yellow)}: #{warning}"
        end
      end
    end
  end
end
