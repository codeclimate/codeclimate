module CC
  class Config
    class JSONAdapter < Config
      DEFAULT_PATH = ".codeclimate.json".freeze

      attr_reader :config

      def self.load(path = DEFAULT_PATH)
        new(::JSON.parse(File.open(path).read))
      end

      def initialize(json = {})
        @config = json
      end
    end
  end
end
