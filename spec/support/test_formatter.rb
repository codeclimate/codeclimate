# frozen_string_literal: true

class TestFormatter
  def initialize
    @strings = [""]
  end

  def write(data)
    @strings << data
  end

  def string
    @strings.join
  end

  def failed(output)
    output
  end
end
