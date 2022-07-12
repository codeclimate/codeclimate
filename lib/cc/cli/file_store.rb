require "fileutils"
require "yaml"

module CC
  module CLI
    class FileStore
      # This class is not supposed to be directly used. It should be sublcassed
      # and a few constants need to be defined on the sublass to be usable.
      #
      # FILE_NAME is the name of the file this class wraps.

      def initialize
        load_data
      end

      def save
        return false unless File.exist? self.class::FILE_NAME

        File.open(self.class::FILE_NAME, "w") do |f|
          YAML.dump data, f
        end

        true
      end

      private

      attr_reader :data

      def load_data
        @data =
          if File.exist? self.class::FILE_NAME
            File.open(self.class::FILE_NAME, "r:bom|utf-8") do |f|
              YAML.safe_load(f, permitted_classes: [Time], permitted_symbols: [], aliases: false, filename: self.class::FILE_NAME)  || {}
            end
          else
            {}
          end
      end
    end
  end
end
