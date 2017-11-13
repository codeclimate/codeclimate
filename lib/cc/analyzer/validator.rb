module CC
  module Analyzer
    module Validator
      attr_reader :error

      def initialize(document)
        @document = document
        validate
      end

      def validate
        return @valid unless @valid.nil?

        if document && invalid_messages.any?
          @error = {
            message: "#{invalid_messages.join("; ")}: `#{document}`.",
            document: document,
          }
          @valid = false
        else
          @valid = true
        end
      end
      alias valid? validate

      private

      attr_reader :document

      def invalid_messages
        @invalid_messages ||= self.class.validations.each_with_object([]) do |check, result|
          validator = check.new(document)
          result << validator.message unless validator.valid?
        end
      end
    end
  end
end
