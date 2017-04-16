require "spec_helper"

module CC::Analyzer
  describe MountedPath do
    describe ".code" do
      subject { described_class.code }

      before { ENV["CODECLIMATE_CODE"] = "/foo" }
      after { ENV.delete "CODECLIMATE_CODE" }

      context "running as a docker container" do
        before { ENV["CODECLIMATE_DOCKER"] = "TRUE" }
        after { ENV.delete "CODECLIMATE_DOCKER" }

        context 'without a configured "CODECLIMATE_CODE_PATH"' do
          it "does not append anything to the host_path" do
            expect(subject.host_path).to eq "/foo"
          end

          it "does not append anything to the container_path" do
            expect(subject.container_path).to eq "/code"
          end
        end

        context 'with a configured "CODECLIMATE_CODE_PATH"' do
          before { ENV["CODECLIMATE_CODE_PATH"] = "bar/baz" }
          after { ENV.delete "CODECLIMATE_CODE_PATH" }

          it 'appends the configured "CODECLIMATE_CODE_PATH" to the host_path' do
            expect(subject.host_path).to eq "/foo/bar/baz"
          end

          it 'appends the configured "CODECLIMATE_CODE_PATH" to the container_path' do
            expect(subject.container_path).to eq "/code/bar/baz"
          end
        end
      end
    end

    describe "#initialize" do
      let(:test_host_prefix) { "/foo" }
      let(:test_container_prefix) { "/code" }
      let(:test_path) { nil }
      let(:test_args) { [test_host_prefix, test_container_prefix, test_path] }
      subject { described_class.new(*test_args) }

      context "with an empty given path" do
        let(:test_path) { "" }
        it "does not assign the given path to @path" do
          expect(subject.instance_variable_get(:@path)).to be_nil
        end
      end

      context "with a given path having only whitespace" do
        let(:test_path) { "               " }
        it "does not assign the given path to @path" do
          expect(subject.instance_variable_get(:@path)).to be_nil
        end
      end

      context "with a given path having leading/trailing whitespace" do
        let(:test_path) { "   bar/baz   " }
        it "assigns to @path the given path with the leading/trailing whitespace removed" do
          # require "byebug"; debugger
          expect(subject.instance_variable_get(:@path)).to eq "bar/baz"
        end
      end
    end
  end
end
