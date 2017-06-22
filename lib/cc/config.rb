require "cc/config/default"
require "cc/config/engine"
require "cc/config/merge"
require "cc/config/prepare"
require "cc/config/yaml"
require "cc/config/yaml/validator"
require "cc/config/json"

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
      config = config.merge(YAML.new) if File.exist?(YAML::DEFAULT_PATH)
      config = config.merge(JSON.new) if File.exist?(JSON::DEFAULT_PATH)
      config
    end

    def initialize(analysis_paths: [], development: false, engines: Set.new, exclude_patterns: [], prepare: Prepare.new)
      @analysis_paths = analysis_paths
      @auto_enable_plugins = true
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

    def auto_enable_plugins?
      @auto_enable_plugins
    end

    def disable_plugins!
      @auto_enable_plugins = false
      @engines.delete_if(&:plugin?)
    end
  end
end
