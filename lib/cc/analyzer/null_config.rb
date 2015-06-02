module CC
  module Analyzer
    class NullConfig < Config
      def initialize(*)
        @config = { "engines" => {} }
      end
    end
  end
end
