class TestContainer
  def initialize(outputs)
    @outputs = outputs
    @on_output = ->(*) { }
  end

  def on_output(*, &block)
    @on_output = block
  end

  def run(*)
    @outputs.each { |output| @on_output.call(output) }
    ::CC::Analyzer::Container::Result.new
  end
end
