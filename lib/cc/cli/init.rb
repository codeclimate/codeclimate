require "cc/analyzer"

module CC
  module CLI
    class Init < Command
      include CC::Analyzer

      CODECLIMATE_YAML = ".testcodeclimate.yml".freeze
      TEMPLATE_CODECLIMATE_YAML = "lib/cc/cli/template_codeclimate_config.yml"
      
      def run
        # print "Generating codeclimate.yaml config file if it doesn't exist"
        # self.show_processing
        # say "\nEdit and then try running 'validate-config' to check configuration."
        say "Generating codeclimate.yml config file if it doesn't exist.\nEdit and then try running 'validate-config' to check configuration."
        create_codeclimate_yaml!
      end

      def filesystem 
        @filesystem ||= Filesystem.new(".")
      end

      def create_codeclimate_yaml!
        if filesystem.exist?(CODECLIMATE_YAML)
          return
        else
          File.open(CODECLIMATE_YAML, "w")
          IO.copy_stream(TEMPLATE_CODECLIMATE_YAML, CODECLIMATE_YAML)
        end
      end

    end
  end
end
