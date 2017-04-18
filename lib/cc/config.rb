require "cc/config/default"
require "cc/config/engine"
require "cc/config/prepare"
require "cc/config/yaml"
require "cc/config/yaml/validator"

module CC
  module Config
    def self.load
      @config ||=
        if File.exist?(YAML::DEFAULT_PATH)
          YAML.new
        else
          Default.new
        end
    end
  end
end
