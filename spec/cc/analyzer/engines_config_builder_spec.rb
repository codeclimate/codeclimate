require "spec_helper"
require "cc/analyzer"

module CC::Analyzer
  describe EnginesConfigBuilder do
    include FileSystemHelpers

    let(:engines_config_builder) do
      EnginesConfigBuilder.new(
        registry: registry,
        config: config,
        container_label: container_label,
        source_dir: source_dir,
        requested_paths: requested_paths
      )
    end
    let(:container_label) { nil }
    let(:requested_paths) { [] }
    let(:source_dir) { "/code" }

    around do |test|
      within_temp_dir { test.call }
    end

    before do
      system("git init > /dev/null")
    end

    describe "with one engine" do
      let(:config) { config_with_engine("an_engine") }
      let(:registry) { registry_with_engine("an_engine") }

      it "contains that engine" do
        result = engines_config_builder.run
        result.size.must_equal(1)
        result.first.name.must_equal("an_engine")
      end
    end

    describe "with an invalid engine name" do
      let(:config) { config_with_engine("an_engine") }
      let(:registry) { {} }

      it "does not raise" do
        engines_config_builder.run
      end
    end

    describe "with engine-specific config" do
      let(:config) do
        CC::Yaml.parse <<-EOYAML
          engines:
            rubocop:
              enabled: true
              config:
                file: rubocop.yml
        EOYAML
      end
      let(:registry) { registry_with_engine("rubocop") }

      it "keeps that config and adds some entries" do
        expected_config = {
          "enabled" => true,
          "config" => "rubocop.yml",
          :include_paths => ["./"]
        }
        result = engines_config_builder.run
        result.size.must_equal(1)
        result.first.name.must_equal("rubocop")
        result.first.registry_entry.must_equal(registry["rubocop"])
        result.first.code_path.must_equal(source_dir)
        result.first.config.must_be(:==, expected_config)
        result.first.container_label.wont_equal nil
      end
    end

    describe "workspace calculation" do
      let(:registry) { registry_with_engine("rubocop", "fixme") }

      describe "with multiple engines & exclude_paths" do
        let(:config) do
          CC::Yaml.parse <<-EOYAML
            engines:
              rubocop:
                enabled: true
              fixme:
                enabled: true
                exclude_paths:
                  - doc/
            exclude_paths:
              - spec/**/*
              - app/b*
          EOYAML
        end

        it "keeps that config and adds some entries" do
          within_temp_dir do
            make_tree <<-EOM
              app/moo.rb
              app/bar.rb
              doc/README
              foo.rb
              spec/bar.rb
            EOM
            expected_rubocop_config = {
              "enabled" => true,
              :include_paths => ["app/moo.rb", "doc/", "foo.rb"]
            }
            expected_fixme_config = {
              "enabled" => true,
              "exclude_paths" => ["doc/"],
              :include_paths => ["app/moo.rb", "foo.rb"]
            }
            result = engines_config_builder.run
            result.size.must_equal(2)
            result[0].name.must_equal("rubocop")
            result[0].registry_entry.must_equal(registry["rubocop"])
            result[0].code_path.must_equal(source_dir)
            result[0].config[:include_paths].sort!
            result[0].config.must_be(:==, expected_rubocop_config)
            result[0].container_label.wont_equal nil
            result[1].name.must_equal("fixme")
            result[1].registry_entry.must_equal(registry["fixme"])
            result[1].code_path.must_equal(source_dir)
            result[1].config[:include_paths].sort!
            result[1].config.must_be(:==, expected_fixme_config)
            result[1].container_label.wont_equal nil
          end
        end
      end

      describe "with no explicit exclude_paths" do
        let(:config) { config_with_engine("rubocop") }

        it "should always exclude the .git directory" do
          within_temp_dir do
            make_tree <<-EOM
              .git/refs/heads/master
              doc/README
              foo.rb
            EOM

            result = engines_config_builder.run
            result.size.must_equal(1)
            result.first.config[:include_paths].sort.must_equal %w[doc/ foo.rb]
          end
        end
      end

      describe "when explicit include paths are given" do
        let(:config) do
          CC::Yaml.parse <<-EOYAML
            engines:
              rubocop:
                enabled: true
            exclude_paths:
              - doc/
          EOYAML
        end
        let(:requested_paths) { ["./doc", "foo.rb"] }

        it "uses the given include paths, and does not exclude" do
          within_temp_dir do
            make_tree <<-EOM
              app/thing.rb
              doc/README
              foo.rb
            EOM

            result = engines_config_builder.run
            result.size.must_equal(1)
            result.first.config[:include_paths].sort.must_equal %w[doc/ foo.rb]
          end
        end
      end
    end

    def registry_with_engine(*names)
      {}.tap do |result|
        names.each do |name|
          result[name] = { "image" => "codeclimate/codeclimate-#{name}" }
        end
      end
    end

    def config_with_engine(*names)
      raw = "engines:\n"
      names.each do |name|
        raw << "  #{name}:\n    enabled: true\n"
      end
      CC::Yaml.parse(raw)
    end

    def null_formatter
      formatter = stub(started: nil, write: nil, run: nil, finished: nil, close: nil)
      formatter.stubs(:engine_running).yields
      formatter
    end
  end
end
