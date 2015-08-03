require "cc/analyzer"

module CC
  module CLI
    module Engines
      autoload :Disable, "cc/cli/engines/disable"
      autoload :Enable, "cc/cli/engines/enable"
      autoload :EngineCommand, "cc/cli/engines/engine_command"
      autoload :Install, "cc/cli/engines/install"
      autoload :List, "cc/cli/engines/list"
      autoload :Remove, "cc/cli/engines/remove"
      autoload :Validate, "cc/cli/engines/validate"
    end
  end
end
