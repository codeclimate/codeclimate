require "cc/analyzer"

module CC
  module CLI
    module Engines
      class Install < EngineCommand
        def run
          say "Pulling uninstalled docker images."
          pull_uninstalled_docker_images
        end

        private

        def pull_uninstalled_docker_images
          engine_names.each do |name|
            if engine_exists?(name)
              image = engine_image(name)
              unless engine_image_installed?(image)
                pull_engine_image(image)
              end
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
          engines_registry_list[engine_name]["image_name"]
        end

        def engine_image_installed?(engine_image)
          docker_history?(engine_image)
        end

        def docker_history?(engine_image)
          system("docker history #{engine_image} > /dev/null 2>&1")
        end

        def pull_engine_image(engine_image)
          system("docker pull #{engine_image}")
        end
      end
    end
  end
end
