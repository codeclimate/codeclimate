require "spec_helper"
require "ostruct"
require 'support/test_formatter'

describe CC::Analyzer::Engine do
  before do
    FileUtils.mkdir_p("/tmp/cc")
  end

  describe "#run" do
    it "uses the image and command in the metadata" do
      expect_docker_run do |*args|
        assert_within(["image", "command"], args)
      end

      run_engine(
        "image" => "image",
        "command" => "command",
      )
    end

    it "supports array commands" do
      expect_docker_run do |*args|
        assert_within(["foo", "bar"], args)
      end

      run_engine("command" => %w[foo bar])
    end

    it "runs the container in a constrained environment" do
      expect_docker_run do |*args|
        assert_within(["--cap-drop", "all"], args)
        assert_within(["--memory", 512_000_000.to_s], args)
        assert_within(["--memory-swap", "-1"], args)
        assert_within(["--net", "none"], args)
      end

      run_engine
    end

    it "parses stdout for null-delimited issues" do
      stdout = StringIO.new
      stdout.write("issue one\0")
      stdout.write("issue two\0")
      stdout.write("issue three")
      stdout.rewind

      expect_docker_run(stdout)

      io = run_engine
      io.string.must_equal("issue oneissue twoissue three")
    end

    it "supports issue filtering by check name" do
      stdout = StringIO.new
      stdout.write(%{{"type":"issue","check":"foo"}\0})
      stdout.write(%{{"type":"issue","check":"bar"}\0})
      stdout.write(%{{"type":"issue","check":"baz"}})
      stdout.rewind

      expect_docker_run(stdout)

      io = run_engine({}, { checks: { bar: { enabled: false } } })
      io.string.wont_match(%{"check":"bar"})
    end

    it "passes stderr to a formatter" do
      expect_docker_run(StringIO.new, StringIO.new, failed_status)

      lambda { run_engine }.must_raise(CC::Analyzer::Engine::EngineFailure)
    end

    it "ensures the container is cleaned up" do
      expect_docker_run do |*args|
        assert_within(["--rm"], args)
      end

      run_engine
    end

    def run_engine(metadata = {}, config = {})
      io = TestFormatter.new
      options = {
        "image" => "codeclimate/image-name",
        "command" => "run",
      }.merge(metadata)
      config.reverse_merge!(exclude_paths: ["foo.rb"])

      engine = CC::Analyzer::Engine.new("rubocop", options, "/path", config.to_json, "sup")
      engine.run(io)

      io
    end

    def expect_docker_run(stdout = StringIO.new, stderr = StringIO.new, status = success_status, &block)
      block ||= ->(*) { :unused }

      Process.expects(:waitpid2).returns([1, status])
      POSIX::Spawn.expects(:popen4).
        with(&block).returns([1, nil, stdout, stderr])
    end

    # Assert that +a+ is included in full, in order within +b+.
    def assert_within(a, b)
      msg = "#{a.inspect} expected to appear within #{b.inspect}"

      if idx = b.index(a.first)
        assert(b[idx, a.length] == a, msg)
      else
        assert(false, msg)
      end
    end

    def success_status
      OpenStruct.new(exitstatus: 0, success?: true)
    end

    def failed_status
      OpenStruct.new(exitstatus: 1, success?: false)
    end
  end
end
