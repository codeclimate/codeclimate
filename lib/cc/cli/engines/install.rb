module CC
  module CLI
    module Engines
      class Install < EngineCommand
        SHORT_HELP = "Pull the latest images for enabled engines in your codeclimate.yml.".freeze

        ImagePullFailure = Class.new(StandardError)

        def run
          require_codeclimate_yml

          say "Pulling docker images."
          pull_docker_images
        end

        private

        def pull_docker_images
          engine_names.each do |name|
            if engine_registry.exists?(name)
              images = engine_registry[name]["channels"].values
              images.each { |image| pull_engine_image(image) }
            else
              warn("unknown engine name: #{name}")
            end
          end
        end

        def engine_names
          @engine_names ||= parsed_yaml.engine_names
        end

        def pull_engine_image(engine_image)
          unless system("docker pull #{engine_image}")
            raise ImagePullFailure, "unable to pull image #{engine_image}"
          end
        end
      end
    end
  end
end
