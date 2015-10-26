module CC
  module Analyzer
    autoload :CompositeContainerListener, "cc/analyzer/composite_container_listener"
    autoload :Config, "cc/analyzer/config"
    autoload :Container, "cc/analyzer/container"
    autoload :ContainerListener, "cc/analyzer/container_listener"
    autoload :Engine, "cc/analyzer/engine"
    autoload :Engines, "cc/analyzer/engines"
    autoload :EngineOutputFilter, "cc/analyzer/engine_output_filter"
    autoload :EngineRegistry, "cc/analyzer/engine_registry"
    autoload :EnginesRunner, "cc/analyzer/engines_runner"
    autoload :Filesystem, "cc/analyzer/filesystem"
    autoload :Formatters, "cc/analyzer/formatters"
    autoload :IncludePathsBuilder, "cc/analyzer/include_paths_builder"
    autoload :IssueSorter, "cc/analyzer/issue_sorter"
    autoload :LocationDescription, "cc/analyzer/location_description"
    autoload :LoggingContainerListener, "cc/analyzer/logging_container_listener"
    autoload :PathPatterns, "cc/analyzer/path_patterns"
    autoload :SourceBuffer, "cc/analyzer/source_buffer"
    autoload :StatsdContainerListener, "cc/analyzer/statsd_container_listener"

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

    UnreadableFileError = Class.new(StandardError)
  end
end
