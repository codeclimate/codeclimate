require "spec_helper"

describe CC::Config::Merge do
  context "analysis paths" do
    describe "#run" do
      it "unions" do
        config1 = CC::Config.new(analysis_paths: ["foo", "bar", "baz"])
        config2 = CC::Config.new(analysis_paths: ["foo", "sup", "bar"])

        described_class.new(config1, config2).run.tap do |config|
          expect(config.analysis_paths.count).to eq(4)
          expect(config.analysis_paths).to include("foo")
          expect(config.analysis_paths).to include("bar")
          expect(config.analysis_paths).to include("baz")
          expect(config.analysis_paths).to include("sup")
        end
      end
    end
  end

  context "development" do
    describe "#run" do
      it "is true if any are true" do
        config1 = CC::Config.new(development: true)
        config2 = CC::Config.new(development: false)
        expect(described_class.new(config1, config2).run.development?).to eq(true)
      end

      it "is false if all are false" do
        config1 = CC::Config.new(development: false)
        config2 = CC::Config.new(development: false)
        expect(described_class.new(config1, config2).run.development?).to eq(false)
      end
    end
  end

  context "engines" do
    describe "#run" do
      it "merges engines and uses right-hand config" do
        config1 = CC::Config.new(
          engines: [
            CC::Config::Engine.new("foo", enabled: true, channel: "foo", config: { foo: "bar", meow: { "yo": "sup" } }),
          ].to_set,
        )

        config2 = CC::Config.new(
          engines: [
            CC::Config::Engine.new("foo", enabled: false, channel: "bar", config: { foo: "baz", meow: { "foo": "bar" } }),
          ].to_set,
        )

        merged_config = described_class.new(config1, config2).run

        expect(merged_config.engines.count).to eq(1)

        merged_config.engines.to_a.first.tap do |engine|
          expect(engine.name).to eq("foo")
          expect(engine.enabled?).to eq(false)
          expect(engine.channel).to eq("bar")
          expect(engine.config).to eq(foo: "baz", meow: { "yo": "sup", "foo": "bar" })
        end
      end

      it "defaults to cronopio channel for duplication" do
        config1 = CC::Config.new(
          engines: [
            CC::Config::Engine.new("duplication", enabled: true, config: { languages: "java" }),
          ].to_set,
        )

        config2 = CC::Config.new(
          engines: [
            CC::Config::Engine.new("duplication", enabled: true, config: { languages: "ruby" }),
          ].to_set,
        )

        merged_config = described_class.new(config1, config2).run

        expect(merged_config.engines.count).to eq(1)

        merged_config.engines.to_a.first.tap do |engine|
          expect(engine.name).to eq("duplication")
          expect(engine.config).to eq(languages: "ruby")
          expect(engine.channel).to eq(CC::Config::Engine::DUPLICATION_CHANNEL)
        end
      end
    end
  end

  context "exclude patterns" do
    describe "#run" do
      it "unions" do
        config1 = CC::Config.new(exclude_patterns: ["foo", "bar", "baz"])
        config2 = CC::Config.new(exclude_patterns: ["foo", "sup", "bar"])

        described_class.new(config1, config2).run.tap do |config|
          expect(config.exclude_patterns.count).to eq(4)
          expect(config.exclude_patterns).to include("foo")
          expect(config.exclude_patterns).to include("bar")
          expect(config.exclude_patterns).to include("baz")
          expect(config.exclude_patterns).to include("sup")
        end
      end
    end
  end

  context "prepare" do
    describe "#run" do
      it "merges prepare configurations" do
        config1 = CC::Config.new(prepare: CC::Config::Prepare.from_yaml("fetch" => ["rubocop.yml"]))
        config2 = CC::Config.new(prepare: CC::Config::Prepare.from_yaml("fetch" => ["eslint.js"]))

        described_class.new(config1, config2).run.tap do |config|
          expect(config.prepare.fetch.each.to_a.count).to eq(2)
          expect(config.prepare.fetch.each.to_a).to include(CC::Config::Prepare::Fetch::Entry.new("rubocop.yml"))
          expect(config.prepare.fetch.each.to_a).to include(CC::Config::Prepare::Fetch::Entry.new("eslint.js"))
        end
      end
    end
  end
end
