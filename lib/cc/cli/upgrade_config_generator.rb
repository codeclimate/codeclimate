require "cc/cli/config_generator"

module CC
  module CLI
    class UpgradeConfigGenerator < ConfigGenerator
      def can_generate?
        errors.blank?
      end

      def errors
        existing_yaml.errors
      end

      def exclude_paths
        (existing_yaml.exclude_paths || []).map(&:to_s)
      end

      def post_generation_verb
        "upgraded"
      end

      private

      def engine_eligible?(engine)
        base_eligible = super
        if engine["upgrade_languages"].present?
          base_eligible && (engine["upgrade_languages"] & classic_languages).any?
        else
          base_eligible
        end
      end

      def classic_languages
        @classic_languages ||= existing_yaml.languages.reject { |_, v| !v }.map(&:first)
      end

      def existing_yaml
        @existing_yaml ||= CC::Yaml.parse(File.read(CODECLIMATE_YAML))
      end
    end
  end
end
