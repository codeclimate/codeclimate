module CC
  module Analyzer
    class Definition
      attr_reader :def_type

      def self.from_hash(source_buffer, definition_hash)
        DefinitionAdapter.new(source_buffer, definition_hash).to_definition
      end

      def initialize(def_type, name, location)
        @def_type = def_type
        @name = name
        @location = location
      end

      def begin_pos
        @location.begin_pos
      end

      def end_pos
        @location.end_pos
      end

      def full_name
        @name.full_name
      end

      def as_json
        {
          def_type:   @def_type,
          full_name:  @name.full_name,
          local_name: @name.local_name,
          location:   @location.as_json
        }
      end

    end
  end
end
