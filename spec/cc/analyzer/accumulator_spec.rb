require "spec_helper"
require "cc/analyzer"

module CC::Analyzer
  describe Accumulator do
    it "accumulates partial messages" do
      flushed = []
      accumulator = Accumulator.new("\0")

      accumulator.on_flush do |chunk|
        flushed << chunk
      end

      accumulator << "entr"
      accumulator << "y 1\0entry 2\0en"
      accumulator << "try 3\0end\0"

      flushed.must_equal([
        "entry 1",
        "entry 2",
        "entry 3",
        "end"
      ])
    end
  end
end

