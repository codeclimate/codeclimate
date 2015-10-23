require "cc/cli/config_generator"

module CC
  module CLI
    class UpgradeConfigGenerator < ConfigGenerator
      def exclude_paths
        [existing_yaml["exclude_paths"]].flatten.select(&:present?)
      end

      def post_generation_verb
        "upgraded"
      end

      private

      def engine_eligible?(engine)
        base_eligble = super
        if engine["upgrade_languages"].present?
          base_eligble && (engine["upgrade_languages"] & classic_languages).any?
        else
          base_eligble
        end
      end

      def classic_languages
        @classic_languages ||= existing_yaml["languages"].reject { |_, v| !v }.map(&:first)
      end

      def existing_yaml
        @existing_yml ||= YAML.safe_load(File.read(CODECLIMATE_YAML))
      end
    end
  end
end
