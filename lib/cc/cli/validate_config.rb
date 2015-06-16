require "cc/yaml"

module CC
  module CLI
    class ValidateConfig < Command
      include CC::Analyzer
      include CC::Yaml

      def run
        require_codeclimate_yml
        verify_yaml
      end

      private

      def verify_yaml
        if any_issues?
          display_issues
        else
          puts colorize("No errors or warnings found in .codeclimate.yml file.", :green)
        end
      end

      def any_issues?
        parsed_yaml.errors? || parsed_yaml.nested_warnings.any? || parsed_yaml.warnings?
      end

      def yaml_content
        filesystem.read_path(CODECLIMATE_YAML).freeze
      end

      def parsed_yaml
        @parsed_yaml ||= CC::Yaml.parse(yaml_content)
      end

      def warnings
        @warnings ||= parsed_yaml.warnings
      end

      def nested_warnings
        @nested_warnings ||= parsed_yaml.nested_warnings
      end

      def errors
        @errors ||= parsed_yaml.errors
      end

      def display_issues
        display_errors
        display_warnings
        display_nested_warnings
      end

      def display_errors
        errors.each do |error|
          puts colorize("ERROR: " + error, :red)
        end
      end

      def display_nested_warnings
        nested_warnings.each do |nested_warning|
          if nested_warning[0][0]
            puts colorize("WARNING in " + nested_warning[0][0] + ": " + nested_warning[1], :red)
          end
        end
      end

      def display_warnings
        warnings.each do |warning|
          puts colorize("WARNING: " + warning, :red)
        end
      end
    end
  end
end
