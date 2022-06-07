require "cc/config/checks_adapter"
require "cc/config/default_adapter"
require "cc/config/engine"
require "cc/config/engine_set"
require "cc/config/json_adapter"
require "cc/config/prepare"
require "cc/config/validation/hash_validations"
require "cc/config/validation/check_validator"
require "cc/config/validation/engine_validator"
require "cc/config/validation/fetch_validator"
require "cc/config/validation/file_validator"
require "cc/config/validation/json"
require "cc/config/validation/prepare_validator"
require "cc/config/validation/yaml"
require "cc/config/yaml_adapter"

module CC
  class Config
    attr_reader \
      :analysis_paths,
      :engines,
      :exclude_patterns,
      :prepare

    attr_writer \
      :development

    def self.load
      config =
        if File.exist?(JSONAdapter::DEFAULT_PATH)
          JSONAdapter.load.config
        elsif File.exist?(YAMLAdapter::DEFAULT_PATH)
          YAMLAdapter.load.config
        else
          {}
        end
      config = DefaultAdapter.new(config).config
      config = ChecksAdapter.new(config).config
      build(config)
    end

    def self.build(data)
      prepare = Prepare.from_data(data["prepare"])
      base_excluded_patterns = data.fetch("exclude_patterns", DefaultAdapter::EXCLUDE_PATTERNS)
      new(
        engines: EngineSet.new(data.fetch("plugins", {})).engines,
        exclude_patterns: base_excluded_patterns + prepare.fetch.paths,
        prepare: prepare,
      )
    end

    def initialize(analysis_paths: [], development: false, engines: [], exclude_patterns: [], prepare: Prepare.new)
      @analysis_paths = analysis_paths
      @development = development
      @engines = engines
      @exclude_patterns = exclude_patterns
      @prepare = prepare
    end

    def merge(other)
      Merge.new(self, other).run
    end

    def development?
      @development
    end

    def disable_plugins!
      @engines.delete_if(&:plugin?)
    end
  end
end
