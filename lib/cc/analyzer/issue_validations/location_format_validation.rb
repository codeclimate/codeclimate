module CC
  module Analyzer
    module IssueValidations
      class LocationFormatValidation < Validation
        class Validator
          def initialize(location)
            @location = location
            check_validity
          end

          def valid?
            error.nil?
          end

          def message
            if error
              "Location is not formatted correctly: #{error}"
            end
          end

          private

          attr_accessor :error

          attr_reader :location

          def check_validity
            if location["lines"]
              self.error = "location.lines is not valid: #{JSON.dump(location["lines"])}" unless valid_lines?(location["lines"])
            elsif location["positions"]
              self.error = "location.positions is not valid: #{JSON.dump(location["positions"])}" unless valid_positions?(location["positions"])
            else
              self.error = "location.lines or location.positions must be present"
            end
          end

          def valid_positions?(positions)
            positions.is_a?(Hash) &&
              valid_position?(positions["begin"]) &&
              valid_position?(positions["end"])
          end

          def valid_position?(position)
            position &&
              (
                [position["line"], position["column"]].all? { |value| value.is_a?(Integer) } ||
                position["offset"].is_a?(Integer)
              )
          end

          def valid_lines?(lines)
            lines.is_a?(Hash) && [lines["begin"], lines["end"]].all? { |value| value.is_a?(Integer) }
          end
        end

        def valid?
          validation.valid?
        end

        def message
          validation.message
        end

        private

        def validation
          @validation ||= Validator.new(object.fetch("location", {}))
        end
      end
    end
  end
end
