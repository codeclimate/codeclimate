class TestContainerLog
  attr_reader :started_image, :timed_out, :finished_status, :finished_stderr

  def started(image)
    @started_image = image
  end

  def timed_out
    @timed_out = true
  end

  def finished(status, stderr)
    @finished_status = status
    @finished_stderr = stderr
  end
end
