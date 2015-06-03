require "cc/analyzer"

module CC
  module CLI
    class Init < Command
      include CC::Analyzer

      CODECLIMATE_YAML = ".codeclimate.yml".freeze
      TEMPLATE_CODECLIMATE_YAML = %{
#
# ---Choose Your Languages---
# To disable analysis for a certain language, set the language to `false`.
# For help setting your languages:
# http://docs.codeclimate.com/article/169-configuring-analysis-languages
#
languages:
   Ruby: true
   JavaScript: true
   Python: true
   PHP: true
#
# ---Exclude Files or Directories---
# List the files or directories you would like excluded from our analysis.
# For help setting your exclude paths:
# http://docs.codeclimate.com/article/166-excluding-files-folders
#
exclude_paths:
 - "test/*"}.freeze
      
      def run
        if filesystem.exist?(CODECLIMATE_YAML)
          say "Config file .codeclimate.yml already present.\nTry running 'validate_config' to check configuration." 
        else
          create_codeclimate_yaml!
          say "Config file .codeclimate.yml successfully generated.\nEdit and then try running 'validate_config' to check configuration."
        end
      end

      private

      def filesystem 
        @filesystem ||= Filesystem.new(".")
      end

      def create_codeclimate_yaml!
        File.open(CODECLIMATE_YAML, "w") do |f|
          f.write(TEMPLATE_CODECLIMATE_YAML)
        end
      end
    end
  end
end
