class TestContainerLog
  attr_reader :started_image, :started_name, :timed_out_seconds, :finished_status, :finished_stderr

  def started(image, name)
    @started_image = image
    @started_name = name
  end

  def timed_out(seconds)
    @timed_out_seconds = seconds
    @timed_out = true
  end

  def timed_out?
    @timed_out
  end

  def finished(status, stderr)
    @finished_status = status
    @finished_stderr = stderr
  end
end
