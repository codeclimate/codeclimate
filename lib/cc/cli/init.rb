module CC
  module CLI
    class Init < Command
      include CC::Analyzer

      def run
        if filesystem.exist?(CODECLIMATE_YAML)
          say "Config file .codeclimate.yml already present.\nTry running 'validate-config' to check configuration."
        else
          create_codeclimate_yaml
          say "Config file .codeclimate.yml successfully generated.\nEdit and then try running 'validate-config' to check configuration."
        end
      end

      private

      def create_codeclimate_yaml
        config = {}
        eligible_engines.each do |engine_name, engine_config|
          config[engine_name] = {
            "enabled" => true
          }
          config["ratings"] ||= {}
          config["ratings"]["paths"] ||= []

          config["ratings"]["paths"] |= engine_config["enable_patterns"]
        end

        File.write(filesystem.path_for(CODECLIMATE_YAML), config.to_yaml)
      end

      def eligible_engines
        CC::Analyzer::EngineRegistry.new.list.each_with_object({}) do |(engine_name, config), result|
          if filesystem.files_matching(config["enable_patterns"]).any?
            result[engine_name] = config
          end
        end
      end
    end
  end
end
