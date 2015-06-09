require "cc/analyzer"
require "cc/yaml"

module CC
  module CLI
    class ValidateConfig < Command
      include CC::Analyzer
      include CC::Yaml

      CODECLIMATE_YAML = ".codeclimate.yml".freeze

      def run
        if filesystem.exist?(CODECLIMATE_YAML)
          verify_yaml
        else
          say "No '.codeclimate.yml' file found. Consider running 'codeclimate init' to generate a valid config file."
        end
      end

      private

      def filesystem
        @filesystem ||= Filesystem.new(".")
      end

      def verify_yaml
        if any_issues?
          display_issues
        else
          say "Great copy!"
        end
      end

      def any_issues?
        parsed_yaml.errors? || parsed_yaml.nested_warnings.any? || parsed_yaml.warnings?
      end

      def yaml_content
        File.read(CODECLIMATE_YAML).freeze
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
          say "ERROR: " + error
        end
      end

      def display_nested_warnings
        nested_warnings.each do |nested_warning|
          if nested_warning[0][0]
            say "WARNING in " + nested_warning[0][0] + ": " + nested_warning[1]
          end
        end
      end

      def display_warnings
        warnings.each do |warning|
          say "WARNING: " + warning
        end
      end
    end
  end
end
