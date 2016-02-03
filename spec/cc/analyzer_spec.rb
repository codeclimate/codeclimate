require 'spec_helper'

describe CC::Analyzer do
  it "can be configured with a statsd" do
    statsd = Object.new
    CC::Analyzer.statsd = statsd
    expect(CC::Analyzer.statsd).to eq statsd
    CC::Analyzer.statsd = CC::Analyzer::DummyStatsd.new
  end
end
