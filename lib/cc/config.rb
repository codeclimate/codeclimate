require "cc/config/default"
require "cc/config/engine"
require "cc/config/engine_set"
require "cc/config/merge"
require "cc/config/prepare"
require "cc/config/yaml_adapter"
require "cc/config/yaml/validator"
require "cc/config/json_adapter"

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
      config = Default.new
      if File.exist?(JSONAdapter::DEFAULT_PATH)
        config = config.merge(build(JSONAdapter.load.config))
      elsif File.exist?(YAMLAdapter::DEFAULT_PATH)
        config = config.merge(build(YAMLAdapter.load.config))
      end
      config
    end

    def self.build(data)
      new(
        engines: EngineSet.new(data.fetch("plugins", {})).engines,
        exclude_patterns: data.fetch("exclude_patterns", Default::EXCLUDE_PATTERNS),
        prepare: Prepare.from_yaml(data["prepare"]),
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
