require 'spec_helper'
require 'cc/analyzer'

describe CC::Analyzer::LinePrinter do
  def output
    @output ||= StringIO.new
  end

  describe "<<" do
    it "prints prefixed output" do
      printer = CC::Analyzer::LinePrinter.new(output, "pre: ")
      printer << "foo\n"
      output.string.must_equal "pre: foo\n"
    end

    it "prints multiple lines" do
      printer = CC::Analyzer::LinePrinter.new(output, "pre: ")
      printer << "foo\n"
      printer << "bar\n"
      output.string.must_equal "pre: foo\npre: bar\n"
    end

    it "prints split lines" do
      printer = CC::Analyzer::LinePrinter.new(output, "pre: ")
      printer << "foo\nba"
      printer << "r\n"
      output.string.must_equal "pre: foo\npre: bar\n"
    end

    it "buffers incomplete lines" do
      printer = CC::Analyzer::LinePrinter.new(output, "pre: ")
      printer << "foo"
      output.string.must_equal ""
    end
  end

  describe "close" do
    it "prints incomplete lines" do
      printer = CC::Analyzer::LinePrinter.new(output, "pre: ")
      printer << "foo"
      printer.close
      output.string.must_equal "pre: foo\n"
    end
  end
end
