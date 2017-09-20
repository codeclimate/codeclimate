module CC
  class Config
    module Validation
      class PrepareValidator
        include HashValidations

        attr_reader :errors, :warnings

        def initialize(data)
          @data = data

          @errors = []
          @warnings = []

          validate
        end

        private

        attr_reader :data

        def validate
          return unless validate_key_type("fetch", Array)

          data.fetch("fetch", []).each do |fetch_data|
            validator = FetchValidator.new(fetch_data)
            validator.errors.each do |msg|
              errors << msg
            end
            validator.warnings.each do |msg|
              warnings << msg
            end
          end

          warn_unrecognized_keys(%w[fetch])
        end
      end
    end
  end
end
