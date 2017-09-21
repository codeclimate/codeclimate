module CC
  module CLI
    module Engines
      class Install < EngineCommand
        SHORT_HELP = "Pull the latest images for enabled engines in your configuration".freeze

        ImagePullFailure = Class.new(StandardError)

        def run
          say "Pulling docker images."
          pull_docker_images
        end

        private

        def config
          @config ||= CC::Config.load
        end

        def pull_docker_images
          config.engines.each(&method(:pull_engine))
        end

        def pull_engine(engine)
          metadata = engine_registry.fetch_engine_details(engine)
          unless system("docker pull #{metadata.image}")
            raise ImagePullFailure, "unable to pull image #{metadata.image}"
          end
        rescue EngineRegistry::EngineDetailsNotFoundError
          warn("unknown engine <#{engine.name}:#{engine.channel}>")
        end
      end
    end
  end
end
