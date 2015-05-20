require "spec_helper"
require 'cc/analyzer'

describe CC::Analyzer::IssueAdapter do
  def source_buffer
    CC::Analyzer::SourceBuffer.new("foo.rb", "foo")
  end

  it "computes fingerprints" do
    adapter = CC::Analyzer::IssueAdapter.new(source_buffer,
      { "check" => "Foo", "location" => { "begin" => { "pos" => 7 } } })
    adapter.to_issue.fingerprint.must_equal "503c5f9370b9e4759ba11f95a6a8a122"
  end

  it "decomposes positions fingerprints" do
    adapter = CC::Analyzer::IssueAdapter.new(source_buffer,
      { "check" => "Foo", "location" => { "begin" => { "pos" => 7 } } })
    adapter.to_issue.begin_pos.must_equal 7
  end
end
