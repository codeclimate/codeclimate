# Validations currently present in CC::Yaml are complex, so we defer to it for
# now to avoid regressions while moving to Quality model. In the future we
# should strangle our use of the gem down to only that, then port it, then
# finally remove it entirely.
require "cc/yaml"

module CC
  class Config
    class YAML
      class Validator
        NestedWarning = Struct.new(:field, :message)

        def initialize(path, registry)
          @path = path
          @registry = registry
          @cc_yaml = CC::Yaml.parse(File.read(path))
        end

        def valid?
          errors.none?
        end

        def errors
          cc_yaml.errors.reject do |msg|
            msg =~ /^No languages or engines key found/
          end
        end

        def warnings
          cc_yaml.warnings.concat(invalid_engine_warnings)
        end

        def nested_warnings
          cc_yaml.nested_warnings.
            map { |x| NestedWarning.new(x[0][0], x[1]) }.
            reject { |x| x.field.nil? || x.field == "ratings" }
        end

        private

        attr_reader :path, :registry, :cc_yaml

        def invalid_engine_warnings
          invalid_engines.map do |engine|
            "unknown engine or channel <#{engine.name}:#{engine.channel}>"
          end
        end

        def invalid_engines
          return [] unless cc_yaml_processable?
          config = CC::Config::YAML.new(path)
          config.engines.reject do |engine|
            engine_exists?(engine)
          end
        end

        def engine_exists?(engine)
          !!registry.fetch_engine_details(engine)
        rescue CC::EngineRegistry::EngineDetailsNotFoundError
          false
        end

        def cc_yaml_processable?
          cc_yaml.errors.none? &&
            cc_yaml.warnings.none? &&
            cc_yaml.nested_warnings.none?
        end
      end
    end
  end
end
