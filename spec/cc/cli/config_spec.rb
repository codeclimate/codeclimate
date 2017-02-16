require "spec_helper"
require "cc/cli/config"

module CC::CLI
  describe CC::CLI::Config do
    describe "#add_engine" do
      it "enables the passed in engine" do
        config = CC::CLI::Config.new()
        engine_config = {
          "default_ratings_paths" => ["foo"]
        }

        config.add_engine("foo", engine_config)

        engine = YAML.load(config.to_yaml)["engines"]["foo"]
        expect(engine).to eq({ "enabled" => true })
      end

      it "copies over default configuration" do
        config = CC::CLI::Config.new()
        engine_config = {
          "default_config" => { "awesome" => true },
          "default_ratings_paths" => ["foo"]
        }

        config.add_engine("foo", engine_config)

        engine = YAML.load(config.to_yaml)["engines"]["foo"]
        expect(engine).to eq(
          "enabled" => true,
          "config" => {
            "awesome" => true
          }
        )
      end

      it "supports engines in non-stable channels by selecting the first entry" do
        config = CC::CLI::Config.new()
        engine_config = {
          "default_ratings_paths" => ["foo"],
          "channels" => [
            [ "beta", "some/path" ],
            [ "gamma", "some/other-path" ],
          ],
        }

        config.add_engine("foo", engine_config)

        engine = YAML.load(config.to_yaml)["engines"]["foo"]
        expect(engine).to eq(
          "enabled" => true,
          "channel" => "beta",
        )
      end
    end

    describe "#add_exclude_paths" do
      it "adds exclude paths to config with glob" do
        config = CC::CLI::Config.new()
        config.add_exclude_paths(["foo/"])

        exclude_paths = YAML.load(config.to_yaml)["exclude_paths"]
        expect(exclude_paths).to eq(["foo/"])
      end

      it "does not glob paths that aren't directories" do
        config = CC::CLI::Config.new()
        config.add_exclude_paths(["foo.rb"])

        exclude_paths = YAML.load(config.to_yaml)["exclude_paths"]
        expect(exclude_paths).to eq(["foo.rb"])
      end
    end
  end
end
