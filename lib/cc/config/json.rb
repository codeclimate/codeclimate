module CC
  module Config
    class JSON
      DEFAULT_PATH = ".codeclimate.json".freeze

      def initialize(path = DEFAULT_PATH)
        @path = path
      end

      def checks
        @checks ||= json.fetch("checks", {})
      end

      private

      attr_reader :path

      def json
        @json ||= {}.tap do |j|
          if File.exist?(path)
            j.merge!(::JSON.parse(File.read(path)))
          end
        end
      end
    end
  end
end
