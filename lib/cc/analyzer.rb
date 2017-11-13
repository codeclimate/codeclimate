require "yaml"

module CC
  module Analyzer
    autoload :Bridge, "cc/analyzer/bridge"
    autoload :CompositeContainerListener, "cc/analyzer/composite_container_listener"
    autoload :Container, "cc/analyzer/container"
    autoload :ContainerListener, "cc/analyzer/container_listener"
    autoload :Engine, "cc/analyzer/engine"
    autoload :EngineOutput, "cc/analyzer/engine_output"
    autoload :EngineOutputFilter, "cc/analyzer/engine_output_filter"
    autoload :EngineOutputOverrider, "cc/analyzer/engine_output_overrider"
    autoload :Filesystem, "cc/analyzer/filesystem"
    autoload :Formatters, "cc/analyzer/formatters"
    autoload :Issue, "cc/analyzer/issue"
    autoload :IssueSorter, "cc/analyzer/issue_sorter"
    autoload :IssueValidations, "cc/analyzer/issue_validations"
    autoload :IssueValidator, "cc/analyzer/issue_validator"
    autoload :LocationDescription, "cc/analyzer/location_description"
    autoload :LoggingContainerListener, "cc/analyzer/logging_container_listener"
    autoload :Measurement, "cc/analyzer/measurement"
    autoload :MeasurementValidations, "cc/analyzer/measurement_validations"
    autoload :MeasurementValidator, "cc/analyzer/measurement_validator"
    autoload :MountedPath, "cc/analyzer/mounted_path"
    autoload :RaisingContainerListener, "cc/analyzer/raising_container_listener"
    autoload :SourceBuffer, "cc/analyzer/source_buffer"
    autoload :SourceExtractor, "cc/analyzer/source_extractor"
    autoload :SourceFingerprint, "cc/analyzer/source_fingerprint"
    autoload :StatsdContainerListener, "cc/analyzer/statsd_container_listener"
    autoload :Validator, "cc/analyzer/validator"

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
