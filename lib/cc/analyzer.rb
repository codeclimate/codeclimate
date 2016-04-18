require "yaml"

module CC
  module Analyzer
    autoload :CompositeContainerListener, "cc/analyzer/composite_container_listener"
    autoload :Config, "cc/analyzer/config"
    autoload :Container, "cc/analyzer/container"
    autoload :ContainerListener, "cc/analyzer/container_listener"
    autoload :Engine, "cc/analyzer/engine"
    autoload :EngineOutput, "cc/analyzer/engine_output"
    autoload :EngineOutputFilter, "cc/analyzer/engine_output_filter"
    autoload :EngineRegistry, "cc/analyzer/engine_registry"
    autoload :EnginesConfigBuilder, "cc/analyzer/engines_config_builder"
    autoload :EnginesRunner, "cc/analyzer/engines_runner"
    autoload :Filesystem, "cc/analyzer/filesystem"
    autoload :Formatters, "cc/analyzer/formatters"
    autoload :Issue, "cc/analyzer/issue"
    autoload :IssueCategoryValidation, "cc/analyzer/issue_category_validation"
    autoload :IssueCheckNamePresenceValidation, "cc/analyzer/issue_check_name_presence_validation"
    autoload :IssueDescriptionPresenceValidation, "cc/analyzer/issue_description_presence_validation"
    autoload :IssueLocationExistenceValidation, "cc/analyzer/issue_location_existence_validation"
    autoload :IssuePathExistenceValidation, "cc/analyzer/issue_path_existence_validation"
    autoload :IssuePathPresenceValidation, "cc/analyzer/issue_path_presence_validation"
    autoload :IssueRelativePathValidation, "cc/analyzer/issue_relative_path_validation"
    autoload :IssueSorter, "cc/analyzer/issue_sorter"
    autoload :IssueTypeValidation, "cc/analyzer/issue_type_validation"
    autoload :IssueValidator, "cc/analyzer/issue_validator"
    autoload :LocationDescription, "cc/analyzer/location_description"
    autoload :LoggingContainerListener, "cc/analyzer/logging_container_listener"
    autoload :MountedPath, "cc/analyzer/mounted_path"
    autoload :RaisingContainerListener, "cc/analyzer/raising_container_listener"
    autoload :SourceBuffer, "cc/analyzer/source_buffer"
    autoload :StatsdContainerListener, "cc/analyzer/statsd_container_listener"
    autoload :Validation, "cc/analyzer/validation"

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
