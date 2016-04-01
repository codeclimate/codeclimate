require "active_support"
require "active_support/core_ext"
require "yaml"
require "cc/analyzer"
require "cc/workspace"
require "cc/yaml"

module CC
  module CLI
    autoload :Analyze, "cc/cli/analyze"
    autoload :Command, "cc/cli/command"
    autoload :Console, "cc/cli/console"
    autoload :Engines, "cc/cli/engines"
    autoload :Help, "cc/cli/help"
    autoload :Init, "cc/cli/init"
    autoload :Runner, "cc/cli/runner"
    autoload :Test, "cc/cli/test"
    autoload :ValidateConfig, "cc/cli/validate_config"
    autoload :Version, "cc/cli/version"

    def self.debug?
      ENV["CODECLIMATE_DEBUG"]
    end

    def self.debug(message, values = {})
      if debug?
        if values.any?
          message << " "
          message << values.map { |k, v| "#{k}=#{v.inspect}" }.join(" ")
        end

        $stderr.puts("[DEBUG] #{message}")
      end
    end
  end
end
