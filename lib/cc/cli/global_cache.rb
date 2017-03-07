require "cc/cli/file_store"

module CC
  module CLI
    class GlobalCache < FileStore
      FILE_NAME = "/cache.yml".freeze

      # Cache entries

      def last_version_check
        data["last-version-check"] || Time.at(0)
      end

      def last_version_check=(value)
        data["last-version-check"] =
          if value.is_a? Time
            value
          else
            Time.at(0)
          end
        save
        value
      end

      def latest_version
        data["latest-version"]
      end

      def latest_version=(value)
        data["latest-version"] = value
        save
        value
      end

      def outdated
        data["outdated"] == true
      end
      alias outdated? outdated

      def outdated=(value)
        data["outdated"] = value == true
        save
        value
      end
    end
  end
end
