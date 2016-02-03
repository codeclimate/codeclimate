require 'spec_helper'

describe CC::Analyzer::SourceBuffer do
  describe "#decompose_position" do
    it "extracts the line and column" do
      buffer = CC::Analyzer::SourceBuffer.new("foo.rb", "foo\nbar")
      line, column = buffer.decompose_position(5)
      expect(line).to eq 2
      expect(column).to eq 1
    end
  end
end
