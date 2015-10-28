module CC
  module CLI
    class Version < Command
      def run
        say version
      end

      private

      def version
        path = File.expand_path("../../../../VERSION", __FILE__)
        @version ||= File.read(path)
      end
    end
  end
end
