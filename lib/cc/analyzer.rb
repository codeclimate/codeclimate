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
    autoload :IssueSorter,        "cc/analyzer/issue_sorter"
    autoload :LocationDescription,"cc/analyzer/location_description"
    autoload :NullConfig,         "cc/analyzer/null_config"
    autoload :SourceBuffer,       "cc/analyzer/source_buffer"
    autoload :UnitName,           "cc/analyzer/unit_name"
  end
end
