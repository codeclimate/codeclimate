module CC
  module Analyzer
    autoload :Accumulator,        "cc/analyzer/accumulator"
    autoload :Config,             "cc/analyzer/config"
    autoload :Engine,             "cc/analyzer/engine"
    autoload :EngineClient,       "cc/analyzer/engine_client"
    autoload :EngineProcess,      "cc/analyzer/engine_process"
    autoload :EngineRegistry,     "cc/analyzer/engine_registry"
    autoload :Filesystem,         "cc/analyzer/filesystem"
    autoload :Formatters,         "cc/analyzer/formatters"
    autoload :NullConfig,         "cc/analyzer/null_config"
    autoload :OutputAccumulator,  "cc/analyzer/output_accumulator"
    autoload :SourceBuffer,       "cc/analyzer/source_buffer"
    autoload :UnitName,           "cc/analyzer/unit_name"
  end
end
