require "spec_helper"

module CC::Analyzer
  describe SourceFingerprint do
    describe "#compute" do
      let(:output) do
        output = {
          "check_name" => "Check/Name",
          "location" => {
            "path" => "spec/fixtures/source.rb"
          },
        }
      end

      it "computes a fingerprint by path, check_name, and source" do
        output["location"]["lines"] = {
          "begin" => 2,
          "end" => 4
        }
        issue = Issue.new("", output.to_json)
        fingerprint = SourceFingerprint.new(issue)

        expect(fingerprint.compute).to eq("30f53a688723a198cd83d3e3377da7d0")
      end

      it "supports positions syntax" do
        output["location"]["positions"] = {
          "begin" => {
            "line" => 2,
            "column" => 7,
          },
          "end" => {
            "offset" => 43,
          },
        }

        issue = Issue.new("", output.to_json)
        fingerprint = SourceFingerprint.new(issue)

        expect(fingerprint.compute).to eq("a3429245fd5f37cfddc9f1a6c7fd31b3")
      end

      it "incorporates partially available source in the fingerprint" do
        output["location"]["lines"] = {
          "begin" => 5,
          "end" => 100
        }
        issue = Issue.new("", output.to_json)
        fingerprint = SourceFingerprint.new(issue)

        expect(fingerprint.compute).to eq("84fbb18391c45d63ddc6f8d528d18ae6")
      end

      it "only incorporates source if source is available" do
        output["location"]["lines"] = {
          "begin" => 1000,
          "end" => 1000
        }
        issue = Issue.new("", output.to_json)
        fingerprint = SourceFingerprint.new(issue)

        expect(fingerprint.compute).to eq("eef541a28f83417a45808139d58b631d")
      end

      it "clears out invalid UTF-8 bytes" do
        output["location"] = {
          "lines" => {
            "begin" => 1,
            "end" => 1
          },
          "path" => "spec/fixtures/stub.rb"
        }

        allow(File).to receive(:file?).and_return(true)
        allow(File).to receive(:read).and_return("hi \255".force_encoding(Encoding::UTF_8))

        issue = Issue.new("", output.to_json)
        fingerprint = SourceFingerprint.new(issue)

        expect(fingerprint.compute).to eq("717ddedd698e51037903bad1d2b06c1b")
      end

      it "excludes the source when the file doesn't exist" do
        output["location"] = {
          "lines" => {
            "begin" => 1,
            "end" => 1
          },
          "path" => "doesnotexist"
        }

        issue = Issue.new("", output.to_json)
        fingerprint = SourceFingerprint.new(issue)

        expect(fingerprint.compute).to eq("8b425ee5d6c63f873d62d9985676b2d9")
      end
    end
  end
end
