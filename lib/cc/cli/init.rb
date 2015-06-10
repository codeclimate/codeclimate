module CC
  module CLI
    class Init < Command
      include CC::Analyzer

      CODECLIMATE_YAML = ".codeclimate.yml".freeze
      TEMPLATE_CODECLIMATE_YAML = %{
#
# ---Choose Your Engines---
# To enable analysis for a certain engine, add engine and set enabled to `true`.
# For help setting your engines:
# http://docs.codeclimate.com/article/169-configuring-analysis-languages #update to engines link
#
engines:
  rubocop:
    enabled: true
  jshint:
    enabled: true
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
          create_codeclimate_yaml
          say "Config file .codeclimate.yml successfully generated.\nEdit and then try running 'validate_config' to check configuration."
        end
      end

      private

      def filesystem
        @filesystem ||= Filesystem.new(ENV['FILESYSTEM_DIR'])
      end

      def create_codeclimate_yaml
        File.open(filesystem.path_for(CODECLIMATE_YAML), "w") do |f|
          f.write(TEMPLATE_CODECLIMATE_YAML)
        end
      end
    end
  end
end
