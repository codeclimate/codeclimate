require "spec_helper"

module CC::Analyzer
  describe StatsdContainerListener do
    let(:engine) { double(name: "engine") }

    describe "#started" do
      it "increments a metric in statsd" do
        statsd = double(increment: nil)
        expect(statsd).to receive(:increment).with("engines.started", tags: ["engine:engine"])

        listener = StatsdContainerListener.new(statsd)
        listener.started(engine, nil)
      end
    end

    describe "#finished" do
      it "increments a metric for success" do
        statsd = double(timing: nil, increment: nil)
        result = double(duration: 10, timed_out?: false, maximum_output_exceeded?: false, exit_status: 0)

        expect(statsd).to receive(:timing).with("engines.time", 10, tags: ["engine:engine"])
        expect(statsd).to receive(:increment).with("engines.finished", tags: ["engine:engine"])
        expect(statsd).to receive(:increment).with("engines.result.success", tags: ["engine:engine"])

        listener = StatsdContainerListener.new(statsd)
        listener.finished(engine, nil, result)
      end

      it "increments a metric for failure" do
        statsd = double(timing: nil, increment: nil)
        result = double(duration: 10, timed_out?: false, maximum_output_exceeded?: false, exit_status: 1)

        expect(statsd).to receive(:timing).with("engines.time", 10, tags: ["engine:engine"])
        expect(statsd).to receive(:increment).with("engines.finished", tags: ["engine:engine"])
        expect(statsd).to receive(:increment).with("engines.result.error", tags: ["engine:engine"])

        listener = StatsdContainerListener.new(statsd)
        listener.finished(engine, nil, result)
      end

      it "increments a metric for maximum output exceeded" do
        statsd = double(timing: nil, increment: nil)
        result = double(duration: 10, timed_out?: false, maximum_output_exceeded?: true)

        expect(statsd).to receive(:timing).with("engines.time", 10, tags: ["engine:engine"])
        expect(statsd).to receive(:increment).with("engines.result.error", tags: ["engine:engine"])
        expect(statsd).to receive(:increment).with("engines.result.error.output_exceeded", tags: ["engine:engine"])

        listener = StatsdContainerListener.new(statsd)
        listener.finished(engine, nil, result)
      end

      it "increments a metric for timeouts" do
        statsd = double(timing: nil, increment: nil)
        result = double(duration: 10, timed_out?: true)

        expect(statsd).to receive(:timing).with("engines.time", 10, tags: ["engine:engine"])
        expect(statsd).to receive(:increment).with("engines.result.error", tags: ["engine:engine"])
        expect(statsd).to receive(:increment).with("engines.result.error.timeout", tags: ["engine:engine"])

        listener = StatsdContainerListener.new(statsd)
        listener.finished(engine, nil, result)
      end

      context "when the engine supports channels" do
        let(:engine) { double(name: "engine", channel: "stable") }

        it "increments a metric for success" do
          statsd = double(timing: nil, increment: nil)
          result = double(duration: 10, timed_out?: false, maximum_output_exceeded?: false, exit_status: 0)

          expect(statsd).to receive(:timing).with("engines.time", 10, tags: ["engine:engine", "channel:stable"])
          expect(statsd).to receive(:increment).with("engines.finished", tags: ["engine:engine", "channel:stable"])
          expect(statsd).to receive(:increment).with("engines.result.success", tags: ["engine:engine", "channel:stable"])

          listener = StatsdContainerListener.new(statsd)
          listener.finished(engine, nil, result)
        end
      end

      context "when the repo_id is included" do
        let(:engine) { double(name: "engine") }
        let(:repo_id) { "123456" }

        it "adds the repo_id to the engine tags" do
          statsd = double(timing: nil, increment: nil)
          result = double(duration: 10, timed_out?: false, maximum_output_exceeded?: false, exit_status: 0)

          expect(statsd).to receive(:increment).with("engines.finished", tags: ["engine:engine", "repo_id:#{repo_id}"])

          listener = StatsdContainerListener.new(statsd, repo_id: repo_id)
          listener.finished(engine, nil, result)
        end
      end
    end
  end
end
