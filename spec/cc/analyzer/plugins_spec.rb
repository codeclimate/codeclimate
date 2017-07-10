require "spec_helper"

describe CC::Analyzer::Plugins do
  around do |spec|
    within_temp_dir { spec.run }
  end

  describe "#auto_enable_engines" do
    it "doesn't do anything by default" do
      config = double(engines: Set.new)

      described_class.new.auto_enable_engines(config)

      expect(config.engines).to be_empty
    end

    it "auto-enables rubocop if .rubocop.yml exists" do
      config = double(engines: Set.new)

      File.write(".rubocop.yml", "")
      described_class.new.auto_enable_engines(config)

      expect(config.engines.length).to eq(1)
      expect(config.engines.first).to be_enabled
      expect(config.engines.first.name).to eq("rubocop")
    end

    it "does not auto-enable over an already-configured engine" do
      engine = CC::Config::Engine.new(
        "rubocop",
        config: { "config" => "mine" },
        enabled: false,
      )
      config = double(engines: Set.new([engine]))

      File.write(".rubocop.yml", "")
      described_class.new.auto_enable_engines(config)

      expect(config.engines.length).to eq(1)
      expect(config.engines.first).not_to be_enabled
      expect(config.engines.first.name).to eq("rubocop")
      expect(config.engines.first.config["config"]).to eq("mine")
    end

    it "checks multiple auto-enable paths" do
      config = double(engines: Set.new)

      File.write(".eslintrc.json", "") # second in list
      described_class.new.auto_enable_engines(config)

      expect(config.engines.length).to eq(1)
      expect(config.engines.first).to be_enabled
      expect(config.engines.first.name).to eq("eslint")
    end
  end
end
