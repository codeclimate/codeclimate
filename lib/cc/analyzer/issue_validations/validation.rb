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

        def path
          object.fetch("location", {})["path"]
        end

        def type
          object["type"]
        end

        def content
          object["content"]
        end
      end
    end
  end
end
