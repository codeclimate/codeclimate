require "safe_yaml/load"

module CC
  module CLI
    class Prepare
      class Quality < Command
        ENGINES_CONFIG = {
          "complexity-ruby" => {
            "enabled" => true,
            "channel" => "beta",
          },
          "duplication" => {
            "enabled" => true,
            "channel" => "cronopio",
            "config" => {
              "languages" => [
                "ruby",
              ],
            },
          },
        }.freeze

        def execute
          Dir.chdir(CC::Analyzer::MountedPath.code.container_path) do
            content =
              if (existing_contents = read_codeclimate_yml)
                modify(existing_contents)
              else
                { "engines" => ENGINES_CONFIG }
              end

            write_codeclimate_yml(content)
          end
        end

        private

        def modify(content)
          content.delete("ratings")
          content["engines"] ||= {}
          content["engines"].merge!(ENGINES_CONFIG)
          content
        end

        def read_codeclimate_yml
          SafeYAML.load_file(CODECLIMATE_YAML)
        rescue Errno::ENOENT
          CLI.debug("No .codeclimate.yml present")
        rescue => ex
          message = "Error reading existing #{CODECLIMATE_YAML}, overwriting."
          $stderr.puts(colorize("WARNING: #{message}", :yellow))
          CLI.debug("error: #{ex.class} - #{ex.message}")
        end

        def write_codeclimate_yml(content)
          yaml = YAML.dump(content)
          CLI.debug("Writing .codeclimate.yml")
          CLI.debug(yaml)
          File.write(CODECLIMATE_YAML, yaml)
        end
      end
    end
  end
end
