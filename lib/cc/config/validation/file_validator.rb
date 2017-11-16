module CC
  class Config
    module Validation
      class FileValidator
        include HashValidations

        attr_reader :errors, :path, :warnings

        def initialize(path, registry)
          @path = path
          @registry = registry

          @errors = []
          @warnings = []

          validate
        end

        def valid?
          errors.none?
        end

        private

        attr_reader :data, :registry

        def validate
          raise NotImplementedError, "use a subclass"
        end

        def denormalize_subvalidator(validator, prefix)
          validator.errors.each do |msg|
            errors << "#{prefix}: #{msg}"
          end
          validator.warnings.each do |msg|
            warnings << "#{prefix}: #{msg}"
          end
        end

        def validate_prepare
          return unless validate_key_type("prepare", Hash)

          validator = PrepareValidator.new(data.fetch("prepare", {}))
          denormalize_subvalidator(validator, "prepare section")
        end

        def validate_engines(key, legacy: false)
          return unless validate_key_type(key, Hash)

          data.fetch(key, {}).each do |engine_name, engine_data|
            engine_validator = EngineValidator.new(engine_data, legacy: legacy)
            denormalize_subvalidator(engine_validator, "engine #{engine_name}")

            if engine_validator.valid?
              validate_engine_existence(engine_name, engine_data)
            end
          end
        end

        def validate_engine_existence(engine_name, engine_data)
          if [true, false].include?(engine_data)
            engine_data = {
              "enabled" => true,
              "channel" => Engine::DEFAULT_CHANNEL,
            }
          end

          engine = Engine.new(
            engine_name,
            enabled: engine_data.fetch("enabled", true),
            channel: engine_data["channel"],
            config: engine_data["config"],
          )
          unless engine_exists?(engine)
            warnings << "unknown engine or channel <#{engine.name}:#{engine.channel}>"
          end
        end

        def engine_exists?(engine)
          !registry.fetch_engine_details(engine).nil?
        rescue CC::EngineRegistry::EngineDetailsNotFoundError
          false
        end

        def validate_checks
          return unless validate_key_type("checks", Hash)

          data.fetch("checks", {}).each do |check_name, check_data|
            validator = CheckValidator.new(check_data)
            denormalize_subvalidator(validator, "check #{check_name}")
          end
        end

        def validate_exclude_pattern(key, legacy: false)
          types =
            if legacy
              [Array, String]
            else
              Array
            end
          return unless validate_key_type(key, types)

          Array(data.fetch(key, [])).each do |pattern|
            unless pattern.is_a?(String)
              errors << "each exclude pattern should be a string, but '#{pattern.inspect}' is a #{pattern.class.to_s.downcase}"
            end
          end
        end
      end
    end
  end
end
