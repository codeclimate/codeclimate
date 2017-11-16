module CC
  module CLI
    class ValidateConfig < Command
      NO_CONFIG_MESSAGE = "No checked in config: nothing to validate.".freeze
      TOO_MANY_CONFIG_MESSAGE = "Don't commit both .codeclimate.yml & .codeclimate.json: only the JSON will be used.".freeze
      SHORT_HELP = "Validate your .codeclimate.yml or .codeclimate.json.".freeze
      VALID_CONFIG_MESSAGE = "No errors or warnings found in %s.".freeze

      def run
        require_json_or_yaml
        process_args

        if any_issues?
          display_issues
        else
          puts format(VALID_CONFIG_MESSAGE, validator.path)
        end

        exit 1 unless validator.valid?
      end

      private

      attr_reader :config, :registry_path, :registry_prefix, :validator

      def process_args
        @registry_path = EngineRegistry::DEFAULT_MANIFEST_PATH
        @registry_prefix = ""

        # Undocumented; we only need these from Builder so we can validate
        # engines/channels against our own registry and prefix.
        while (arg = @args.shift)
          case arg
          when "--registry" then @registry_path = @args.shift
          when "--registry-prefix" then @registry_prefix = @args.shift
          end
        end
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

      def require_json_or_yaml
        if !filesystem.exist?(Config::YAMLAdapter::DEFAULT_PATH) && !filesystem.exist?(Config::JSONAdapter::DEFAULT_PATH)
          puts NO_CONFIG_MESSAGE
          exit 0
        elsif filesystem.exist?(Config::YAMLAdapter::DEFAULT_PATH) && filesystem.exist?(Config::JSONAdapter::DEFAULT_PATH)
          puts "#{colorize("WARNING", :yellow)}: #{TOO_MANY_CONFIG_MESSAGE}"
        end
      end

      def validator
        @validator =
          if filesystem.exist?(Config::JSONAdapter::DEFAULT_PATH)
            Config::Validation::JSON.new(
              Config::JSONAdapter::DEFAULT_PATH,
              engine_registry,
            )
          elsif filesystem.exist?(Config::YAMLAdapter::DEFAULT_PATH)
            Config::Validation::YAML.new(
              Config::YAMLAdapter::DEFAULT_PATH,
              engine_registry,
            )
          end
      end

      def engine_registry
        EngineRegistry.new(registry_path, registry_prefix)
      end
    end
  end
end
