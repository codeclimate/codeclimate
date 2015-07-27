module CC
  module Yaml
    module TestHelpers
      FILENAME = ".codeclimate.yml".freeze

      def create_codeclimate_yaml(content)
        File.write(FILENAME, content)
      end

      def expect_codeclimate_yaml
        yaml = File.read(FILENAME)
        config = CC::Yaml.parse(yaml)

        if block_given?
          yield config
        else
          config
        end
      end
    end
  end
end
