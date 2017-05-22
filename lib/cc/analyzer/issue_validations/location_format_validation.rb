module CC
  module Analyzer
    module IssueValidations
      class LocationFormatValidation < Validation
        class Validator
          def initialize(location)
            @location = location
          end

          def valid?
            if location["lines"]
              valid_lines?(location["lines"])
            elsif location["positions"]
              valid_positions?(location["positions"])
            else
              false
            end
          end

          private

          attr_reader :location

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
          Validator.new(object.fetch("location", {})).valid?
        end

        def message
          "Location is not formatted correctly"
        end
      end
    end
  end
end
