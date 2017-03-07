require "fileutils"
require "yaml"

module CC
  module CLI
    class XDGFile
      # This class is not supposed to be directly used. It should be sublcassed
      # and a few constants need to be defined on the sublass to be usable.
      #
      # XDG_HOME is the direcory to store files in. E.g.~/.config
      # XDG_ENV_VAR is the name of the env var to take an override from.
      # NAMESPACE is the dirname under the directory to put our files in. E.g
      # "codeclimate".
      # FILE_NAME is the name of the file this class wraps.

      def initialize
        load_data
      end

      def save
        dir = File.dirname(file_name)
        unless Dir.exist? dir
          FileUtils.mkdir_p dir
        end

        File.open(file_name, "w") do |f|
          YAML.dump data, f
        end

        true
      end

      private

      attr_reader :data

      def load_data
        @data =
          if File.exist? file_name
            File.open(file_name, "r:bom|utf-8") do |f|
              YAML.safe_load(f, [Time], [], false, file_name) || {}
            end
          else
            {}
          end
      end

      def file_name
        File.expand_path(
          File.join(
            ENV.fetch(self.class::XDG_ENV_VAR, self.class::XDG_HOME),
            self.class::NAMESPACE,
            self.class::FILE_NAME,
          ),
        )
      end
    end
  end
end
