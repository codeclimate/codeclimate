require "cc/version"

module CC
  module CLI
    class Version < Command

      def run
        say CC::VERSION
      end

    end
  end
end
