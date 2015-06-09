require "cc/analyzer"

module CC
  module CLI
    class Engines
      class Enable < Command
        include CC::Analyzer
        include CC::Yaml

        CODECLIMATE_YAML = ".codeclimate.yml".freeze
        BUFFER = "  ".freeze
        ENGINE = "rubocop" #or args

        def run
          if filesystem.exist?(CODECLIMATE_YAML)
            update_yaml
          else
            create_yaml(engine)
          end
        end


        private

        def filesystem
          @filesystem ||= Filesystem.new(".")
        end

        def yaml_content
          File.read(CODECLIMATE_YAML).freeze
        end

        def parsed_yaml
          binding.pry
          @parsed_yaml ||= CC::Yaml.parse(yaml_content)
        end

        def update_yaml

        end

        def yaml_has_engine?
          parsed_yaml.engines.include(ENGINE)
        end

        def add_engine_to_yaml
          contents = File.read(CODECLIMATE_YAML)
          File.open(CODECLIMATE_YAML, "w") do |f|
            f.write(TEMPLATE_CODECLIMATE_YAML)
          end
        end

        def enable_engine
        end
      end
    end
  end
end
