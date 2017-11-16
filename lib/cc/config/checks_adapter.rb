module CC
  class Config
    class ChecksAdapter
      attr_reader :config

      def initialize(data = {})
        @config = data

        return unless checks.present?
        copy_qm_checks_config
      end

      private

      def copy_qm_checks_config
        DefaultAdapter::ENGINES.keys.each do |name|
          copy_checks(name)
        end
      end

      def copy_checks(engine_name)
        engine = config.fetch("plugins", {}).fetch(engine_name, {})
        engine["config"] ||= {}

        if engine["config"].is_a?(String)
          engine["config"] = {
            "file" => engine["config"],
            "checks" => checks,
          }
        elsif engine["config"].is_a?(Hash)
          engine["config"]["checks"] = checks
        end
      end

      def checks
        config["checks"]
      end
    end
  end
end
