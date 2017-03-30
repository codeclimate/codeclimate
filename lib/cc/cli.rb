require "active_support"
require "active_support/core_ext"
require "yaml"
require "cc/analyzer"
require "cc/workspace"
require "cc/yaml"

require "cc/cli/analyze"
require "cc/cli/command"
require "cc/cli/console"
require "cc/cli/engines"
require "cc/cli/help"
require "cc/cli/init"
require "cc/cli/output"
require "cc/cli/prepare"
require "cc/cli/prepare/quality"
require "cc/cli/runner"
require "cc/cli/test"
require "cc/cli/validate_config"
require "cc/cli/version"

module CC
  module CLI
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
