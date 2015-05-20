require 'spec_helper'
require 'cc/analyzer'

describe CC::Analyzer::SourceBuffer do
  describe "#decompose_position" do
    it "extracts the line and column" do
      buffer = CC::Analyzer::SourceBuffer.new("foo.rb", "foo\nbar")
      line, column = buffer.decompose_position(5)
      line.must_equal 2
      column.must_equal 1
    end
  end
end
