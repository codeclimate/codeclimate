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
              yaml_safe_load(f)
            end
          else
            {}
          end
      end

      def yaml_safe_load(yaml)
        if Gem::Version.new(Psych::VERSION) >= Gem::Version.new("3.1.0.pre1") # Ruby 2.6
          YAML.safe_load(
            yaml,
            whitelist_classes: [Time],
            whitelist_symbols: [],
            aliases: false,
            filename: self.class::FILE_NAME,
          ) || {}
        else
          YAML.safe_load(yaml, [Time], [], false, self.class::FILE_NAME) || {}
        end
      end
    end
  end
end
