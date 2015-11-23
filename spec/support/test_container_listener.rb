class TestContainerListener < CC::Analyzer::ContainerListener
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

  def started(data)
    @started_image = data.image
    @started_name = data.name
  end

  def timed_out(data)
    @timed_out_image = data.image
    @timed_out_name = data.name
    @timed_out_seconds = data.duration / 1_000
    @timed_out = true
  end

  def timed_out?
    @timed_out
  end

  def finished(data)
    @finished_image = data.image
    @finished_name = data.name
    @finished_status = data.status
    @finished_stderr = data.stderr
  end
end
