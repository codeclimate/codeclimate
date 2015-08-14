require "spec_helper"

class CC::Analyzer::Engine
  describe ContainerLog do
    describe "#started" do
      it "forwards the call to the inner log" do
        inner_log = TestContainerLog.new
        container_log = ContainerLog.new("", inner_log)

        container_log.started("image", "name")

        inner_log.started_image.must_equal "image"
        inner_log.started_name.must_equal "name"
      end
    end

    describe "#timed_out" do
      it "forwards the call to the inner log" do
        inner_log = TestContainerLog.new
        container_log = ContainerLog.new("", inner_log)

        container_log.timed_out(900) rescue nil

        inner_log.timed_out?.must_equal true
        inner_log.timed_out_seconds.must_equal 900
      end

      it "raises Engine::EngineTimeout" do
        inner_log = TestContainerLog.new
        container_log = ContainerLog.new("", inner_log)

        action = ->() { container_log.timed_out(900) }
        action.must_raise(EngineTimeout)
      end
    end

    describe "#finished" do
      it "forwards the call to the inner log" do
        status = stub(success?: true)
        inner_log = TestContainerLog.new
        container_log = ContainerLog.new("", inner_log)

        container_log.finished(status, "stderr")

        inner_log.finished_status.must_equal status
        inner_log.finished_stderr.must_equal "stderr"
      end

      it "raises an Engine::EngineFailure if unsuccessful" do
        status = stub(success?: false, exitstatus: 1)
        inner_log = TestContainerLog.new
        container_log = ContainerLog.new("", inner_log)

        action = ->() { container_log.finished(status, "stderr") }
        action.must_raise(EngineFailure)
      end
    end
  end
end
