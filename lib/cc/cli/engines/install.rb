require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Install < EngineCommand
        ImagePullFailure = Class.new(StandardError)

        def run
          require_codeclimate_yml

          say "Pulling docker images."
          pull_docker_images
        end

        private

        def pull_docker_images
          engine_names.each do |name|
            if engine_exists?(name)
              image = engine_image(name)
              pull_engine_image(image)
            else
              warn("unknown engine name: #{name}")
            end
          end
        end

        def engine_names
          @engine_names ||= parsed_yaml.engine_names
        end

        def engine_exists?(engine_name)
          engines_registry_list.keys.include?(engine_name)
        end

        def engine_image(engine_name)
          engines_registry_list[engine_name]["image"]
        end

        def pull_engine_image(engine_image)
          if !system("docker pull #{engine_image}")
            raise ImagePullFailure, "unable to pull image #{engine_image}"
          end
        end
      end
    end
  end
end
