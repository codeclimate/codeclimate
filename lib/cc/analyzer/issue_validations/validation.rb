module CC
  module Analyzer
    module IssueValidations
      class Validation
        def initialize(object)
          @object = object
        end

        def valid?
          raise NotImplementedError
        end

        def message
          raise NotImplementedError
        end

        private

        attr_reader :object
      end
    end
  end
end
