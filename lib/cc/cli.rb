require "active_support"
require "active_support/core_ext"
require "cc/analyzer"
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
    autoload :Version, "cc/cli/version"
  end
end
