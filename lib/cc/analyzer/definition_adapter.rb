require "digest/md5"

module CC
  module Analyzer
    class DefinitionAdapter

      def initialize(source_buffer, definition_hash)
        @source_buffer = source_buffer
        @definition_hash = definition_hash
      end

      def to_definition
        begin_pos = @definition_hash["location"]["begin"]["pos"]
        end_pos = @definition_hash["location"]["end"]["pos"]

        source_range = SourceRange.new(begin_pos, end_pos)
        location = SourceLocation.new(@source_buffer, source_range)

        full_name = @definition_hash["full_name"]
        local_name = @definition_hash["name"]
        unit_name = UnitName.new(full_name, local_name)

        def_type = @definition_hash["def_type"]
        Definition.new(def_type, unit_name, location)
      end

    end
  end
end
