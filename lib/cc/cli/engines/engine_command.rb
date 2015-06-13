require "cc/analyzer"

module CC
  module CLI
    module Engines
      class EngineCommand < Command
        include CC::Analyzer

        CODECLIMATE_YAML = ".codeclimate.yml".freeze

        def run
          raise NotImplementedError, "Must be implemented by child command."
        end

        NotImplemented = Class.new(StandardError)

        protected

        def engine_name
          @engine_name ||= @args.first
        end

        def parsed_yaml
          @parsed_yaml ||= CC::Analyzer::Config.new(yaml_content)
        end

        def yaml_content
          File.read(CODECLIMATE_YAML).freeze
        end

        def update_yaml
          File.open(filesystem.path_for(CODECLIMATE_YAML), "w") do |f|
            f.write(parsed_yaml.to_yaml)
          end
        end

        def engine_present_in_yaml?
          parsed_yaml.engine_present?(engine_name)
        end

        def engine_enabled?
          parsed_yaml.engine_enabled?(engine_name)
        end

        def engine_exists?
          engines_registry_list.keys.include?(engine_name)
        end

        def engines_registry_list
          @engines_registry_list ||= CC::Analyzer::EngineRegistry.new.list
        end

        def filesystem
          @filesystem ||= Filesystem.new(ENV['FILESYSTEM_DIR'])
        end
      end
    end
  end
end
