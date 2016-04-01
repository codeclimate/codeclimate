module CC
  module Analyzer
    module Formatters
      class Spinner
        def initialize(text)
          @spinner = TTY::Spinner.new(text)
        end

        def start
          return unless $stdout.tty? && !CLI.debug?
          @thread = Thread.new do
            loop do
              @spinning = true
              spinner.spin
              sleep 0.075
            end
          end
        end

        def stop(text = "Done!")
          if @spinning
            spinner.stop(text)
            print("\n")
            @thread.kill
          end
          @spinning = false
        end

        private

        attr_reader :spinner
      end
    end
  end
end
