module CC
  module Analyzer
    autoload :Accumulator,        "cc/analyzer/accumulator"
    autoload :Config,             "cc/analyzer/config"
    autoload :Engine,             "cc/analyzer/engine"
    autoload :EngineClient,       "cc/analyzer/engine_client"
    autoload :EngineOutputFilter, "cc/analyzer/engine_output_filter"
    autoload :EngineRegistry,     "cc/analyzer/engine_registry"
    autoload :EnginesRunner,      "cc/analyzer/engines_runner"
    autoload :Filesystem,         "cc/analyzer/filesystem"
    autoload :Formatters,         "cc/analyzer/formatters"
    autoload :IssueSorter,        "cc/analyzer/issue_sorter"
    autoload :LocationDescription,"cc/analyzer/location_description"
    autoload :NullConfig,         "cc/analyzer/null_config"
    autoload :PathPatterns,       "cc/analyzer/path_patterns"
    autoload :SourceBuffer,       "cc/analyzer/source_buffer"
    autoload :UnitName,           "cc/analyzer/unit_name"

    class DummyStatsd
      def method_missing(*)
        yield if block_given?
      end
    end

    class DummyLogger
      def method_missing(*)
        yield if block_given?
      end
    end

    cattr_accessor :statsd, :logger
    self.statsd = DummyStatsd.new
    self.logger = DummyLogger.new
  end
end
