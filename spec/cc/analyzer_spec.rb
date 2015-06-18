require 'spec_helper'

describe CC::Analyzer do
  it "can be configured with a statsd" do
    statsd = Object.new
    CC::Analyzer.statsd = statsd
    CC::Analyzer.statsd.must_equal statsd
    CC::Analyzer.statsd = nil
  end
end
