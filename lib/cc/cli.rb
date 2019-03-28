require "active_support"
require "active_support/core_ext"
require "yaml"
require "cc/analyzer"
require "cc/config"
require "cc/engine_registry"
require "cc/workspace"

require "cc/cli/analyze"
require "cc/cli/command"
require "cc/cli/console"
require "cc/cli/engines"
require "cc/cli/help"
require "cc/cli/output"
require "cc/cli/prepare"
require "cc/cli/runner"
require "cc/cli/validate_config"
require "cc/cli/version"

module CC
  module CLI
    def self.debug?
      ENV["CODECLIMATE_DEBUG"].present?
    end

    def self.logger
      @logger ||= ::Logger.new(STDERR).tap do |logger|
        logger.level =
          if debug?
            ::Logger::DEBUG
          else
            ::Logger::ERROR
          end
      end
    end
  end

  Analyzer.logger = CLI.logger
end
