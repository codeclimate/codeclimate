require "securerandom"

module CC
  module Analyzer
    class Engine
      attr_reader :name

      def initialize(name, metadata, code_path, config_json, label)
        @name = name
        @metadata = metadata
        @code_path = code_path
        @config_json = config_json
        @label = label.to_s
      end

      def run(stdout_io, stderr_io = StringIO.new)
        EngineProcess.new(self, stdout_io, stderr_io).run
      end

      def command
        [
          "docker", "run",
          "--rm",
          "--cap-drop", "all",
          "--label", "com.codeclimate.label=#{@label}",
          "--name", container_name,
          "--memory", 512_000_000.to_s, # bytes
          "--memory-swap", "-1",
          "--net", "none",
          "--volume", "#{@code_path}:/code:ro",
          "--env-file", env_file,
          "--user", "9000:9000",
          @metadata["image"],
          @metadata["command"], # nil, String or Array
        ].flatten.compact
      end

      private

      def container_name
        @container_name ||= "cc-engines-#{name}-#{SecureRandom.uuid}"
      end

      def env_file
        contents = "ENGINE_CONFIG=#{@config_json}"

        # This is going away anyway
        # if contents.size > 64 * 1024
        #   raise EngineFailure, "Config for engine #{name} exceeds 64k character limit"
        # end

        path = File.join("/tmp/cc", SecureRandom.uuid)
        File.write(path, contents)
        path
      end
    end
  end
end
