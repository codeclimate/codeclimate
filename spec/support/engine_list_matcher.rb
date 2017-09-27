# expect(config).to match_engines([
#  Engine.new("duplication", enabled: true)
#  Engine.new("rubocop", enabled: true, config: foo),
# ])
RSpec::Matchers.define(:match_engines) do |expected|
  match do |actual|
    missing_engines(actual.engines, expected).empty? &&
      extra_engines(actual.engines, expected).empty? &&
      misconfigured_engines(actual.engines, expected).empty?
  end

  failure_message do |actual|
    msg = "expect to match engine list:\n"

    if (missing = missing_engines(actual.engines, expected)).any?
      msg << "  - missing engines: #{missing.map(&:name).inspect}\n"
    end

    if (extra = extra_engines(actual.engines, expected)).any?
      msg << "  - extra engines: #{extra.map(&:name).inspect}\n"
    end

    misconfigured_msgs(actual.engines, expected).each do |engine_msg|
      msg << "  - #{engine_msg}\n"
    end

    msg
  end

  def missing_engines(actual, expected)
    expected - actual
  end

  def extra_engines(actual, expected)
    actual - expected
  end

  def misconfigured_engines(actual, expected)
    actual.select do |engine|
      expected_engine = expected.detect { |e| e == engine }
      expected_engine && (
        expected_engine.enabled? != engine.enabled? ||
          expected_engine.channel != engine.channel ||
          expected_engine.exclude_patterns != engine.exclude_patterns ||
          expected_engine.config != engine.config
      )
    end
  end

  def misconfigured_msgs(actual, expected)
    misconfigured_engines(actual, expected).flat_map do |engine|
      expected_engine = expected.detect { |e| e == engine }
      [:enabled?, :channel, :config, :exclude_patterns].map do |attr|
        if expected_engine.send(attr) != engine.send(attr)
          "expected #{engine.name}.#{attr} to be #{expected_engine.send(attr).inspect}, got #{engine.send(attr).inspect}."
        end
      end
    end.compact
  end
end
