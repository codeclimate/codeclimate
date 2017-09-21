require "spec_helper"

module CC::CLI
  describe ValidateConfig do
    around do |spec|
      Dir.chdir(Dir.mktmpdir) { spec.run }
    end

    describe "#run" do
      it "reports no errors if no file is committed" do
        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match("nothing to validate")
        expect(code).to be_zero
      end

      it "reports warning if too many files are committed" do
        write_cc_yaml("foo")
        write_cc_json("{}")

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match("only the JSON will be used")
        expect(code).to be_zero
      end

      it "reports yaml errors and exits nonzero" do
        write_cc_yaml(<<-EOYAML)
        engkxhfgkxfhg: sdoufhsfogh: -
        0-
        fgkjfhgkdjfg;h:;
          sligj:
        oi i ;
        EOYAML

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match("ERROR")
        expect(code).to be_nonzero
      end

      it "reports yaml warnings but does not exit nonzero" do
        write_cc_yaml(<<-EOYAML)
        engines:
          rubocop:
            enabled: true
        EOYAML

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match("WARNING")
        expect(code).to be_zero
      end

      it "reports yaml errors and warnings together" do
        write_cc_yaml(<<-EOYAML)
        engines:
          rubocop:
            enabled: true
          jshint:
            not_enabled
        EOYAML

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match("engine jshint: section must be a boolean or a hash")
        expect(stdout).to match("'engines' has been deprecated")
        expect(code).to be_nonzero
      end

      it "reports copy looks great for valid yaml" do
        write_cc_yaml(<<-EOYAML)
        version: "2"
        plugins:
          rubocop:
            enabled: true
        EOYAML

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match(/no errors or warnings/i)
        expect(code).to be_zero
      end

      it "warns of invalid engines or channels in yaml" do
        write_cc_yaml(<<-EOYAML)
        engines:
          rubocop:
            enabled: true
          eslint:
            enabled: true
            channel: madeup
          madeup:
            enabled: true
        EOYAML

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to include("unknown engine or channel <madeup:stable>")
        expect(stdout).to include("unknown engine or channel <eslint:madeup>")
        expect(code).to be_zero
      end
    end

    it "reports json errors and exits nonzero" do
      write_cc_yaml(JSON.generate(
        plugins: "foobar"
      ))

      stdout, _stderr, code = capture_io_and_exit_code do
        ValidateConfig.new.run
      end

      expect(stdout).to match("ERROR")
      expect(stdout).to match("'plugins' must be a hash")
      expect(code).to be_nonzero
    end

    def write_cc_yaml(content)
      File.write(".codeclimate.yml", content)
    end

    def write_cc_json(content)
      File.write(".codeclimate.json", content)
    end
  end
end
