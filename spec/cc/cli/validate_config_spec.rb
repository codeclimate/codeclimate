require "spec_helper"

module CC::CLI
  describe ValidateConfig do
    around do |spec|
      Dir.chdir(Dir.mktmpdir) { spec.run }
    end

    describe "#run" do
      it "reports errors and exits nonzero" do
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

      it "reports warnings but does not exit nonzero" do
        write_cc_yaml(<<-EOYAML)
        unknown_key:
        - hey
        - there
        EOYAML

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match("WARNING")
        expect(code).to be_zero
      end

      it "reports warnings in nested keys" do
        write_cc_yaml(<<-EOYAML)
        engines:
          rubocop:
        EOYAML

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match("invalid \"engines\" section: invalid \"rubocop\" section: missing key \"enabled\"")
        expect(code).to be_nonzero
      end

      it "reports errors and nested warnings together" do
        write_cc_yaml(<<-EOYAML)
        engines:
          rubocop:
            enabled: true
          jshint:
            not_enabled
        strange_key:
        EOYAML

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match("invalid \"engines\" section: invalid \"jshint\" section: unexpected scalar, missing key \"enabled\"")
        expect(stdout).to match("unexpected key \"strange_key\", dropping")
        expect(code).to be_nonzero
      end

      it "reports copy looks great for valid configs" do
        write_cc_yaml(<<-EOYAML)
        engines:
          rubocop:
            enabled: true
        EOYAML

        stdout, _stderr, code = capture_io_and_exit_code do
          ValidateConfig.new.run
        end

        expect(stdout).to match(/no errors or warnings/i)
        expect(code).to be_zero
      end

      it "warns of invalid engines or channels" do
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

    def write_cc_yaml(content)
      File.write(".codeclimate.yml", content)
    end
  end
end
