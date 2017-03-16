require "cc/cli/file_store"
require "uuid"

module CC
  module CLI
    class GlobalConfig < FileStore
      FILE_NAME = "/config.yml".freeze

      DEFAULT_CONFIG = {
        "check-version" => true,
      }.freeze

      # Config entries

      def check_version
        data["check-version"]
      end
      alias check_version? check_version

      def check_version=(value)
        data["check-version"] = value == true
      end

      def uuid
        data["uuid"] ||= UUID.new.generate
      end

      private

      def load_data
        @data = DEFAULT_CONFIG.merge(super)
      end
    end
  end
end
