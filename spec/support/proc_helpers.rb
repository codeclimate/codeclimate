require "cc/cli/command"

module ProcHelpers
  def capture_io
    stdout = $stdout
    stderr = $stdout

    $stdout = StringIO.new
    $stderr = StringIO.new

    yield

    [$stdout.string, $stderr.string]
  rescue SystemExit => ex
    fail  "Unexpected SystemExit in capture_io: stdout=#{$stdout.string}, stderr=#{$stderr.string}"
  ensure
    $stdout = stdout
    $stderr = stdout
  end

  def capture_io_and_exit_code
    exit_code = 0

    stdout, stderr = capture_io do
      begin
        yield
      rescue SystemExit => ex
        exit_code = ex.status
      end
    end

    return stdout, stderr, exit_code
  end
end

RSpec.configure do |conf|
  conf.include(ProcHelpers)
end
