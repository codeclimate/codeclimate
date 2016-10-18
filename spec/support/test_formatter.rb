class TestFormatter
  attr_accessor :string

  def initialize
    @string = ""
  end

  def write(data)
    string << data
  end

  def errored(output)
    output
  end
end
