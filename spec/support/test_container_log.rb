class TestContainerLog
  attr_reader \
    :started_image,
    :started_name,
    :timed_out_image,
    :timed_out_name,
    :timed_out_seconds,
    :finished_image,
    :finished_name,
    :finished_status,
    :finished_stderr

  def started(image, name)
    @started_image = image
    @started_name = name
  end

  def timed_out(image, name, seconds)
    @timed_out_image = image
    @timed_out_name = name
    @timed_out_seconds = seconds
    @timed_out = true
  end

  def timed_out?
    @timed_out
  end

  def finished(image, name, status, stderr)
    @finished_image = image
    @finished_name = name
    @finished_status = status
    @finished_stderr = stderr
  end
end
