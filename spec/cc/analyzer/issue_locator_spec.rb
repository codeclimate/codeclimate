require 'spec_helper'
require 'ostruct'
require 'cc/analyzer'

describe CC::Analyzer::IssueLocator do
  describe "#definition_at" do
    it "works with no definitions" do
      locator = CC::Analyzer::IssueLocator.new([])
      locator.definition_at(0).must_equal nil
    end

    it "locates positions in definitions" do
      definition = OpenStruct.new(begin_pos: 0, end_pos: 10)

      locator = CC::Analyzer::IssueLocator.new([definition])
      locator.definition_at(0).must_equal definition
      locator.definition_at(5).must_equal definition
      locator.definition_at(10).must_equal definition
    end

    it "ignores positions outside definitions" do
      definition = OpenStruct.new(begin_pos: 1, end_pos: 10)

      locator = CC::Analyzer::IssueLocator.new([definition])
      locator.definition_at(0).must_equal nil
      locator.definition_at(11).must_equal nil
    end

    it "locates positions in nested definitions" do
      outer = OpenStruct.new(begin_pos: 0, end_pos: 10)
      inner = OpenStruct.new(begin_pos: 1, end_pos: 9)

      locator = CC::Analyzer::IssueLocator.new([outer, inner])
      locator.definition_at(1).must_equal inner
      locator.definition_at(5).must_equal inner
      locator.definition_at(9).must_equal inner

      locator = CC::Analyzer::IssueLocator.new([inner, outer])
      locator.definition_at(1).must_equal inner
      locator.definition_at(5).must_equal inner
      locator.definition_at(9).must_equal inner
    end
  end
end
