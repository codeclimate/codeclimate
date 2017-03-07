require "cc/cli/xdg_file"
require "uuid"

module CC
  module CLI
    class GlobalConfig < XDGFile
      XDG_ENV_VAR = "XDG_CONFIG_HOME".freeze
      XDG_HOME = "~/.config".freeze
      NAMESPACE = "codeclimate".freeze
      FILE_NAME = "config.yml".freeze

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
