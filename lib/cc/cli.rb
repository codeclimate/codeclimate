require "active_support"
require "active_support/core_ext"
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

    class Logger
      def debug(message, values = {})
        if ENV["CODECLIMATE_DEBUG"]
          if values.any?
            message << " "
            message << values.map { |k, v| "#{k}=#{v.inspect}" }.join(" ")
          end

          # Leading and trailing newlines to prevent mangling
          $stderr.print("\n[DEBUG] #{message}\n")
        end
      end

      # Any non-DEBUG output is handled not via logging
      def method_missing(*)
        yield if block_given?
      end
    end

    CC::Analyzer.logger = Logger.new
  end
end
