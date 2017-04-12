module CC
  module CLI
    class Version < Command
      SHORT_HELP = "Display the CLI version.".freeze

      def run
        say self.class.latest
      end

      def self.latest
        path = File.expand_path("../../../../VERSION", __FILE__)
        @version ||= File.read(path).chomp
      end
    end
  end
end
