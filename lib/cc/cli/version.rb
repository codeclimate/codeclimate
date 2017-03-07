module CC
  module CLI
    class Version < Command
      SHORT_HELP = "Display the CLI version.".freeze

      def run
        say version
      end

      def version
        path = File.expand_path("../../../../VERSION", __FILE__)
        @version ||= File.read(path)
      end
    end
  end
end
